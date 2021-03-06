if (!file.exists(paste0(drake.path, "/data/data.Rdata"))  ){
  file.names<-download_aemo_aggregated(year=2010:lubridate::year(Sys.Date()), months=1:12, local.path=local.path)
#download_aemo_current( local.path=local.path )
  # NSW1 = get_aemo_data(state='NSW') # %>% padr::pad()
  # VIC1 = get_aemo_data(state='VIC') 
  # SA1  = get_aemo_data(state='SA') 
  # QLD1 = get_aemo_data(state='QLD') 
  # TAS1 = get_aemo_data(state='TAS') 
  # aemo = data.table::rbindlist(list(NSW1,QLD1,SA1,TAS1,VIC1))  
  aemo= build_aemo()
  gas.use  <-
     data.table::fread(paste0(drake.path,   "/data/OpenNEM.csv"))[,c(1,7:10)] 
  gas.use$date<-gas.use$date %>% lubridate::dmy_hm()
     names(gas.use) <-  c("date","gas_recip", "gas_ocgt", "gas_ccgt", "gas_steam")
    
     gas.use  <- gas.use  %>%   dplyr::mutate( year= lubridate::year(date),
                                             month=lubridate::month(date),
                                             date = lubridate::ymd(paste0(year,"-",month,"-15")),
                   sum = gas_ccgt+gas_ocgt+gas_steam,
                   efficiencyLower =(gas_ccgt*.45 +gas_ocgt*.3 + gas_steam*.3 )/sum,
                   efficiencyUpper =(gas_ccgt*.5 + gas_ocgt*.35 + gas_steam*.35 )/sum)  %>%
       subset(year>=2010) %>%
       dplyr::select(year,month,gas_ccgt,gas_ocgt,gas_steam,date,sum,efficiencyLower,efficiencyUpper)
                               
  names(gas.use)
  # gas.use  <-data.table::fread(paste0(drake.path, "/data/gas_generation.csv"))%>%
  #   purrr::set_names(~ stringr::str_to_lower(.)) %>% 
  #   dplyr::mutate(date = lubridate::ymd(paste0(year,"-",month,"-15")),
  #                 sum = gas_ccgt+gas_ocgt+gas_steam,
  #                 efficiencyLower =(gas_ccgt*.45 +gas_ocgt*.3 + gas_steam*.3 )/sum,
  #                 efficiencyUpper =(gas_ccgt*.5 + gas_ocgt*.35 + gas_steam*.35 )/sum) 
  gas.tidy = tidyr::gather(gas.use[,1:5], gas.type,value, -year, -month) %>% 
    dplyr::mutate(date = lubridate::ymd(paste0(year,"-",month,"-15")) ,
                  mdays = lubridate::days_in_month(date),
                #  mw= value*1e3/(mdays*24)*12, 
                  mw = value*1e3/(mdays*24),
                  gas.type=stringr::str_remove_all(gas.type, "gas_")) 
  
  # nb 5 regions being summed so length is 5x number of time increments
  
  NEM.month = aemo %>% 
    dplyr::group_by(year, month) %>% 
    dplyr::summarise(date=mean(SETTLEMENTDATE) %>% as.Date(),
                     VWP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
                     TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND)/2 )   %>%
    head(-1)
  
  
  NEM.year =  NEM.month %>% 
    dplyr::group_by(year) %>% 
    dplyr::summarise(date=mean(date) ,
                     VWP = sum(VWP*TOTALDEMAND)/sum(TOTALDEMAND), 
                     TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND)/2)

lng = update_gladstone( local.path=local.path)  %>% subset( !is.na(tonnes))
save( lng, gas.use, gas.tidy, NEM.month, NEM.year, file = paste0(drake.path,"/data/data.Rdata"))

} else {
  
 load(paste0(drake.path, "/data/data.Rdata"))
 day.dif <-Sys.Date()- (tail(NEM.month,2)[1,])$date  # %>% mutate(date= lubridate::ymd(year,month, "01")) # year and date of last records in NEM.month

# current.year <- lubridate::year(Sys.Date())
# <- lubridate::year(Sys.Date())
 last.month <- tail(NEM.month,2)$month[1]
 last.year <-  tail(NEM.month,2)$year[1]
 next.year<- last.year
while (day.dif >15+30+6) {  #note that GPA  Cargo sttas are usuall not posted until at least 5 days into follwoing month
     next.month<-  (last.month+1)
    if (next.month==13) {next.month<- 1; next.year<- next.year+1}
    day.dif<- day.dif-zoo::as.yearmon("2007-12") %>% lubridate::days_in_month()
    
    file.names<-download_aemo_aggregated(
                                         local.path=local.path,
                                         months=next.month,
                                         verbose=F,
                                         years=next.year)
    files <- tail(file.names, 1) %>% strtrim(10)
    aemo= build_aemo(files=files)
    NEM.month = rbind(NEM.month, aemo %>% 
      dplyr::group_by(year, month) %>% 
      dplyr::summarise(date=mean(SETTLEMENTDATE) %>% as.Date(),
                       VWP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
                       TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND)/2 )   %>%
      head(-1))
                                         
    NEM.year = NEM.month %>% 
      dplyr::group_by(year) %>% 
      dplyr::summarise(date=mean(date),
                       VWP = sum(VWP*TOTALDEMAND)/sum(TOTALDEMAND), 
                       TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND)/2)
    
    lng <-rbind(lng, read_gladstone_ports(year=next.year, month=next.month, fuel="Liquefied Natural Gas", country="Total" ) )
}
  save( lng, gas.use, gas.tidy, NEM.month, NEM.year, file = paste0(drake.path,"/data/data.Rdata"))
  
}
  



