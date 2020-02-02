#--------
#drake plan
#------
load("./data/aemo.CO2EII.RDATA")  # need to amke this updatable.

pkgconfig::set_config('drake::strings_in_dots' = 'literals')
reproplan = drake::drake_plan(
  #add data munging here
  #CO2EII  %>% names()
  
  nem = CO2EII %>%
    subset(REGIONID=="NEM") %>%
    dplyr::rename(te="TOTAL_EMISSIONS", date="SETTLEMENTDATE", co="CORRECTION") %>%
    dplyr::mutate(year=lubridate::year(date), month=lubridate::month(date), quarter=lubridate::quarter(date)),
  
  nem.month = nem %>%
    dplyr::group_by(year, month) %>%
    dplyr::summarise(total=mean(te), date=mean(date), total.corrected=mean(co*te)) %>%
    tidyr::gather(n, te, -date, -year, -month),
  
  nem.quarter = nem %>%
    dplyr::group_by(year, quarter) %>%
    dplyr::summarise(total=sum(te), date=mean(date), total.corrected=sum(co*te)) %>%
    tidyr::gather(n, te, -date, -year, -quarter),
  
  nem.year = nem %>%
    dplyr::group_by(year ) %>%
    dplyr::summarise(total=mean(te), date=mean(date), total.corrected=mean(co*te)) %>%
    tidyr::gather(n, te, -date, -year)%>% 
    dplyr::mutate(time= dplyr::case_when(year < 2005 ~ "low", year >=2005~ "high")),
  
  
 # nem.year.te.2005 = nem.year$te[nem.year$year=="2005" &nem.year$n=="total.corrected" ],
  #gas.con.mtoe = reproscir::BP_all(verbose=F, sheet=27, countries="Australia", years=1969:2017 , units="Tonnes", data=T ),
   # nem.year.te.2005 = nem.year$te[nem.year$year=="2005"],
  gas.con = reproscir::BP_all(verbose=F, sheet=28, countries="Australia", years=1969:2018 , units="bcm", data=T ),
  gas.prod = reproscir::BP_all(verbose=F, sheet=25, countries="Australia", years=1969:2018 , units="bcm", data=T ),

  gas.con.t = reproscir::BP_all(verbose=F, sheet=30, countries="Australia", years=1969:2018 , units="mtoe", data=T ) %>% 
    dplyr::mutate(time= dplyr::case_when(year < 2005 ~ "low", year >=2005~ "high")),
   
  oil.con = reproscir::BP_all(verbose=F, sheet=12, countries="Australia", years=1969:2018 , units="mtoe", data=T ) %>% 
    dplyr::mutate(time= dplyr::case_when(year < 2005 ~ "low", year >=2005~ "high")),
  coal.con = reproscir::BP_all(verbose=F, sheet=40, countries="Australia", years=1969:2018 , units="mtoe", data=T ) %>% 
    dplyr::mutate(time= dplyr::case_when(year < 2005 ~ "low", year >=2005~ "high")),
  
  emissions = reproscir::BP_all(verbose=F, sheet=65, countries="Australia", years=1969:2018 , units="mt", data=T ) %>% 
    dplyr::mutate(time= dplyr::case_when(year < 2005 ~ "low", year >=2005~ "high")),
   
 ob  = merge(reproscir::BP_all(sheet =12, countries="Australia" )$data,
            reproscir::BP_all(sheet =8, countries="Australia" )$data,
            by =c("year", "region")) ,
 oil.balance =ob%>%
   dplyr::mutate(import =value.x-value.y) %>%
   dplyr::rename(consumption=value.x, production=value.y) %>%
   tidyr::pivot_longer(cols=c(consumption, production, import)),
 
 
#rint(nem.year.te.2005),
  #merged.data =merge(x,y)
  p010 = plots( nem.month ,nem.quarter, nem.year, gas.con, gas.prod , gas.con.t, oil.con, coal.con, emissions, ob, oil.balance )

)
