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
    tidyr::gather(n, te, -date, -year),
  
  nem.year.te.2005 = nem.year$te[nem.year$year=="2005" &nem.year$n=="total.corrected" ],
  
 # nem.year.te.2005 = nem.year$te[nem.year$year=="2005"],
  
#rint(nem.year.te.2005),
  #merged.data =merge(x,y)
  p010 = plots( nem.month  )

)
