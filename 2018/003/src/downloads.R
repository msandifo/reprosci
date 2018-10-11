
my.tz="GMT"
tm_to_tjd <-function(n,date) n*8.97/172/lubridate::days_in_month(date)
set_month_day <-function(date, day=15) date+lubridate::days(day-lubridate::mday(date))



file.names<-reproscir::download_aemo_aggregated(year=2008:2018, months=1:12, local.path=NULL)
aemo= reproscir::read_aemo_aggregated()

NEM.month = aemo %>% 
  dplyr::group_by(year, month) %>% 
  dplyr::summarise(date=mean(SETTLEMENTDATE) %>% as.Date(),
                   RRP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
                   TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND) )   %>%
  head(-1)


gld = reproscir::update_gladstone( )  %>% subset( !is.na(tonnes)) %>% 
  dplyr::mutate(gasdate=date %>% set_month_day(15), actualquantity= tm_to_tjd(tonnes, date))
# 
# gasbb<- reproscir::download_gasbb() %>%  
#   reproscir::read_gasbb( ) 
# t1<-spread(test,  flowdirection, actualquanti )%>% glimpse()

load("./data/facility.Rdata")
prod.ids<-(gasbb.facility %>% subset(PlantType=="PROD"))$PlantID
stor.ids<-(gasbb.facility %>% subset(PlantType=="STOR"))$PlantID
pipe.ids<-(gasbb.facility %>% subset(PlantType=="PIPE"))$PlantID

gasbb.prod <-  reproscir::download_gasbb() %>%  
  reproscir::read_gasbb( ) %>% 
  subset(plantid %in% prod.ids  )

gasbb.stor <-  reproscir::download_gasbb() %>%  
  reproscir::read_gasbb( ) %>% 
  subset(plantid %in% stor.ids  )

gasbb.pipe <-  reproscir::download_gasbb() %>%  
  reproscir::read_gasbb( ) %>% 
  subset(plantid %in% pipe.ids  )


gasbb.prod.zone<-rbind(gasbb.prod %>% 
                         reproscir::group_gasbb("Roma")  %>% 
                         dplyr::mutate(ZoneName="Roma"),
                       gasbb.prod %>% 
                         reproscir::group_gasbb("Moom") %>% 
                         dplyr::mutate(ZoneName="Moomba"),
                       gasbb.prod %>% 
                         reproscir::group_gasbb("Gipps") %>% 
                         dplyr::mutate(ZoneName="Gippsland"),
                       gasbb.prod %>% 
                         reproscir::group_gasbb("Port") %>% 
                         dplyr::mutate(ZoneName="Port Campbell"),
                       gasbb.prod %>% 
                         reproscir::group_gasbb("Ball") %>% 
                         dplyr::mutate(ZoneName="Ballera"), 
                       gasbb.prod %>% 
                         reproscir::group_gasbb("Vic") %>% 
                         dplyr::mutate(ZoneName="Victoria"),
                       gasbb.prod %>% 
                         reproscir::group_gasbb("Syd")%>% 
                         dplyr::mutate(ZoneName="Sydney")) 

gasbb.prod.zone.month <- 
  gasbb.prod.zone %>% subset(actualquantity<1e4) %>%
  dplyr::mutate(month=lubridate::month(gasdate),year=lubridate::year(gasdate)) %>%
  dplyr:: group_by(ZoneName, month, year) %>% 
  dplyr::summarise(actualquantity=mean(actualquantity), 
                   gasdate=mean(gasdate) %>% set_month_day(15)) %>% 
  dplyr::arrange(gasdate)

gasbb.prod.zone.month$ZoneName<- factor(gasbb.prod.zone.month$ZoneName, 
                                        levels= (c( 
                                          'Sydney',
                                          'Ballera',
                                          'Moomba','Victoria',
                                          'Port Campbell',
                                          'Gippsland',
                                          'Roma'
                                        )), ordered=TRUE)

gasbb.prod.zone.gld.month<-dplyr::left_join( gasbb.prod.zone.month %>% subset(ZoneName=="Roma"), 
                                      gld, by=c("gasdate", "month", "year")) %>% 
  dplyr::arrange(gasdate)
gasbb.prod.zone.gld.month$actualquantity.y[is.na(gasbb.prod.zone.gld.month$actualquantity.y)]<-0
gasbb.prod.zone.month$roma =0
gasbb.prod.zone.month$roma[gasbb.prod.zone.month$ZoneName=="Roma"] <-  gasbb.prod.zone.gld.month$actualquantity.y


save( NEM.month , gasbb.prod.zone.month,  file = paste0(drake.path,"/data/data.Rdata"))
 
  



