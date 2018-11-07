#--------
#drake plan
#------

reproplan = drake::drake_plan(
  NEM.month = reproscir::read_aemo_aggregated()%>% 
    dplyr::group_by(year, month) %>% 
    dplyr::summarise(date=mean(SETTLEMENTDATE) %>% as.Date(),
                     VWP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
                     TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND)/2 )   %>%
    head(-1),
  
  
   gladstone=reproscir::update_gladstone() %>%
     dplyr::mutate(gasdate = date %>% reproscir::set_month_day(15),  # 
                   actualquantity = reproscir::lng_tm_to_tjd(tonnes, date)), #get_gladstone_month(),
  gasbb.prod.zone.month =get_gasbb_zone_month(gladstone),
  p003 = plots(NEM.month, gasbb.prod.zone.month )
)
