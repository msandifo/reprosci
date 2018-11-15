#--------
#drake plan
#------
load("./data/aemo.CO2EII.RDATA")

pkgconfig::set_config('drake::strings_in_dots' = 'literals')
reproplan = drake::drake_plan(
  #add data munging here
  #CO2EII  %>% names()
  
  nem = CO2EII %>%
    subset(REGIONID=="NEM") %>%
    dplyr::rename(te="TOTAL_EMISSIONS", date="SETTLEMENTDATE", co="CORRECTION") %>%
    dplyr::mutate(year=lubridate::year(date), month=lubridate::month(date)),
  
  nem.month = nem %>%
    dplyr::group_by(year, month) %>%
    dplyr::summarise(total=mean(te), date=mean(date), total.corrected=mean(co*te)) %>%
    tidyr::gather(n, te, -date, -year, -month),
  
  nem.year = nem %>%
    dplyr::group_by(year ) %>%
    dplyr::summarise(total=mean(te), date=mean(date), total.corrected=mean(co*te)) %>%
    tidyr::gather(n, te, -date, -year)%>% 
    dplyr::mutate(time= dplyr::case_when(year < 2005 ~ "low", year >=2005~ "high")),
  
  
  nem.year.te.2005 = nem.year$te[nem.year$year=="2005" &nem.year$n=="total.corrected" ],
  #gas.con.mtoe = reproscir::BP_all(verbose=F, sheet=27, countries="Australia", years=1969:2017 , units="Tonnes", data=T ),
   # nem.year.te.2005 = nem.year$te[nem.year$year=="2005"],
  gas.con = reproscir::BP_all(verbose=F, sheet=25, countries="Australia", years=1969:2017 , units="bcm", data=T ),
  gas.prod = reproscir::BP_all(verbose=F, sheet=22, countries="Australia", years=1969:2017 , units="bcm", data=T ),

  gas.con.t = reproscir::BP_all(verbose=F, sheet=27, countries="Australia", years=1969:2017 , units="mtoe", data=T ) %>% 
    dplyr::mutate(time= dplyr::case_when(year < 2005 ~ "low", year >=2005~ "high")),
   
  oil.con = reproscir::BP_all(verbose=F, sheet=9, countries="Australia", years=1969:2017 , units="bcm", data=T ) %>% 
    dplyr::mutate(time= dplyr::case_when(year < 2005 ~ "low", year >=2005~ "high")),
  
#rint(nem.year.te.2005),
  #merged.data =merge(x,y)
  p010 = plots( nem.month ,nem.year, gas.con, gas.prod , gas.con.t, oil.con )

)
