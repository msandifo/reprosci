if (!file.exists(paste0(drake.path, "/data/data.Rdata")) | full.repro){
  file.names<-download_aemo_aggregated(year=2007:2018, months=1:12, local.path=local.path, states="QLD")
  QLD1 = get_aemo_data(state='QLD') 
  QLD.month = QLD1 %>% 
      dplyr::group_by(year, month) %>% 
      dplyr::summarise(date=mean(SETTLEMENTDATE) %>% as.Date(),
                     RRP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
                     TOTALDEMAND= sum(TOTALDEMAND)/length(TOTALDEMAND) )   %>%
  head(-1)
  lng = update_gladstone( local.path=local.path)  %>% subset( !is.na(tonnes))
   
  gasbb <- reproscir::download_gasbb() %>%  
    reproscir::read_gasbb( ) %>% 
     reproscir::group_gasbb("Roma") %>% 
    dplyr::mutate(year= lubridate::year(gasdate), month= lubridate::month(gasdate)) %>%
    dplyr::group_by(year,month) %>%
    dplyr::summarise(date=mean(gasdate), TOTALDEMAND = mean(reproscir::tjday_to_mw(actualquantity)))
  
  save( QLD.month, lng, gasbb , file = paste0(drake.path,"/data/data.Rdata"))
  
    
  
} else {
  load(paste0(drake.path, "/data/data.Rdata"))
  day.dif <-Sys.Date()- (tail(QLD.month,2)[1,])$date  # %>% mutate(date= lubridate::ymd(year,month, "01")) # year and date of last records in NEM.month
  current.year <- lubridate::year(Sys.Date())
  current.month <- lubridate::month(Sys.Date())
  last.month <- tail(QLD.month,2)$month[1]
  last.year <-  tail(QLD.month,2)$year[1]
  next.year<- last.year
  while (day.dif >15+31) {  
     next.month<-  (last.month+1)
    if (next.month==13) {next.month<- 1; next.year<- next.year+1}
    day.dif<- day.dif- (lubridate::ymd(paste0(current.year,"-",current.month, "-15")) %>% lubridate::days_in_month())
    file.names<-download_aemo_aggregated(
                                         local.path=local.path,
                                         months=next.month,
                                         verbose=F,
                                         years=next.year,  states="QLD")
    QLD1 = get_aemo_data(state='QLD', files=file.names) 
    QLD.month  = rbind(  QLD.month , QLD1 %>% 
      dplyr::group_by(year, month) %>% 
      dplyr::summarise(date=mean(SETTLEMENTDATE) %>% as.Date(),
                       RRP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
                       TOTALDEMAND= sum(TOTALDEMAND)/length(TOTALDEMAND) )  %>%
      head(-1))
    lng = update_gladstone( local.path=local.path)  %>% subset( !is.na(tonnes))
}
 save( QLD.month,lng, gasbb, file = paste0(drake.path,"/data/data.Rdata"))
 
}
  



