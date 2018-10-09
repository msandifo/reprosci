#--------
#drake plan
#------

reproplan = drake::drake_plan(
  lng = update_gladstone( local.path=local.path),
  NSW1 = get_aemo_data(state='NSW'),# %>% padr::pad()
  VIC1 = get_aemo_data(state='VIC'),
  SA1  = get_aemo_data(state='SA'),
  QLD1  =get_aemo_data(state='QLD'),
  TAS1  =get_aemo_data(state='TAS'),
  aemo = data.table::rbindlist(list(NSW1,QLD1,SA1,TAS1,VIC1)) ,
  gas.use= gas.use <-data.table::fread(paste0(drake.path, "/data/gas_generation.csv"))%>%
    purrr::set_names(~ stringr::str_to_lower(.)) %>% 
    dplyr::mutate(date = lubridate::ymd(paste0(year,"-",month,"-15")),
                  sum = gas_ccgt+gas_ocgt+gas_steam,
                  efficiencyLower =(gas_ccgt*.45 +gas_ocgt*.3 + gas_steam*.3 )/sum,
                  efficiencyUpper =(gas_ccgt*.5 + gas_ocgt*.35 + gas_steam*.35 )/sum),
  gas.tidy = tidyr::gather(gas.use[,1:5], gas.type,value, -year, -month) %>% 
    dplyr::mutate(date = lubridate::ymd(paste0(year,"-",month,"-15")) ,
                  mdays = lubridate::days_in_month(date),
                  mw= value*1e3/(mdays*24)*12, 
                  gas.type=stringr::str_remove_all(gas.type, "gas_")),
  
  # nb 5 regions being summed so lenegth is 5x number of time increments
  
  NEM.month = aemo %>% 
    dplyr::group_by(year, month) %>% 
    dplyr::summarise(date=mean(SETTLEMENTDATE)%>% as.Date(),
                     RRP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
                     TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND) )  ,
  
  
  NEM.year = aemo %>% 
    dplyr::group_by(year) %>% 
    dplyr::summarise(date=mean(SETTLEMENTDATE) %>% as.Date(),
                     RRP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
                     TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND)),
  reprosci001.plot= reprosci001(lng, NEM.month, NEM.year),
  reprosci002.plot= reprosci002(gas.use,gas.tidy, NEM.month ),
  reprosci003.plot= reprosci003( gas.use,gas.tidy  )
  
  
)
