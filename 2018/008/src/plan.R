#--------
#drake plan
#------
pkgconfig::set_config('drake::strings_in_dots' = 'literals')
reproplan = drake::drake_plan(
  #add data munging here
  eia.us.cbm.mon =reproscir::read_data("eia.us.cbm.withdrawals.month",data=T ) %>%
    dplyr::rename(cbm=US) %>%
    dplyr::mutate( date=as.Date(date)) ,#shoul correctly adjust for days inmonth
  
  eia.us.cbm.ann=reproscir::read_data("eia.us.cbm.withdrawals.annual" ,data=T) %>%
    dplyr::rename(cbm=US, date=date) %>%
    dplyr::mutate( date=as.Date(date)) ,
  
  eia.us.ng.mon=reproscir::read_data("eia.us.ng.withdrawals.month", data=T )[,c(2,3)]%>% 
    dplyr::rename(us.gas=us) %>%
    dplyr::mutate(us.gas=us.gas, date=as.Date(date)) ,#shoul correctly adjust for days inmonth
  
  eia.us.ng.ann=reproscir::read_data("eia.us.ng.withdrawals.annual", data=T),
  
  prb.monthly.data = read.csv(paste(getwd(),"data/powder.river.basin.cbm.csv" ,sep="/")) %>% 
    dplyr::select(c("Month.Year", "Total.Gas.Mcf", "Total.Water.Bbls")) %>% 
    dplyr::rename(date=Month.Year, prb.cbm=Total.Gas.Mcf  ) %>%
    dplyr::mutate(date=stringr::str_c("15-", date) %>%
                    as.Date("%d-%b-%y"), prb.cbm = prb.cbm/1e3*30 ,  # MCF/DAY -> MMCF/MONTH
                  Cum.Water.Bbls = cumsum(as.numeric(Total.Water.Bbls))),

    us.cbm.data =read_data("eia.us.cbm.annual", data=T) %>% 
    dplyr::rename(date= Date)%>% 
    dplyr::mutate(cbm= US*1e9/tj2cf/365, date=as.Date(date))  ,
  
  roma.daily.data = reproscir::download_gasbb() %>%
    reproscir::read_gasbb( ) %>%  
    dplyr::group_by(gasdate,zonename) %>% 
    subset(zonename =="Roma (ROM)"  & flowdirection =="DELIVERY") %>%
    dplyr::summarise(actualquantity=sum(actualquantity,na.rm=T) ) %>% 
    dplyr::arrange(gasdate) ,
  
  
  roma.monthly.data=roma.daily.data %>% 
    dplyr::mutate(month=lubridate::month(gasdate), year=lubridate::year(gasdate) ) %>%
    dplyr::group_by(month,year) %>%
    dplyr::summarise(actualquantity=mean(actualquantity,na.rm=T), gasdate=mean(gasdate) ) %>% 
    dplyr::arrange(gasdate),
  
  merged.data =dplyr::bind_rows(prb.monthly.data[,c(1,2)] %>% 
                                   dplyr::rename(val=prb.cbm) %>% 
                                   dplyr::mutate(val=val*1e3/tj2cf , region="Powder River Basin, Wyoming"),
                                 roma.monthly.data[,c(4,3)] %>%   
                                   dplyr::rename(date=gasdate, val=actualquantity)%>% 
                                   dplyr::mutate(region="Roma, Qld"),
                                 us.cbm.data[, c(1,2)] %>% 
                                   dplyr::rename(val=US) %>% 
                                   dplyr::mutate( val=val*1e6*1e3/tj2cf/365,region="US Total"), 
                                 # data.frame(date= us.cbm.data$date, 
                                 #            val=rowSums(us.cbm.data[, c("Wyoming")] ,na.rm=TRUE)*1e6*1e3/tj2cf/365, 
                                 #            region="Wyoming"),
                                 data.frame(date= us.cbm.data$date, 
                                            val=rowSums(us.cbm.data[, c("New.Mexico","Colorado","Utah")] ,na.rm=TRUE)*1e6*1e3/tj2cf/365, 
                                            region="New Mexico, Colarado, Utah")),
  
  #merged.data =merge(x,y)
  p008= plots( merged.data, prb.monthly.data, roma.monthly.data,us.cbm.data,eia.us.ng.ann )

)
