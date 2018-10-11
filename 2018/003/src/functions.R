library(readxl)
library(magrittr)
library(ggplot2)
library(hrbrthemes)
library(dplyr)
library(lubridate)
library(purrr)
library(stringr)
library(tidyverse)
library(reproscir)
my.tz="GMT"
tm_to_tjd <-function(n,date) n*8.97/172/lubridate::days_in_month(date)
set_month_day <-function(date, day=15) date+lubridate::days(day-lubridate::mday(date))



file.names<-download_aemo_aggregated(year=2008:2018, months=1:12, local.path=NULL)
aemo= read_aemo_aggregated()

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

load("/Volumes/data/Dropbox/msandifo/documents/programming/r/twitter/2018/002/data/facility.Rdata")
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
  arrange(gasdate)

gasbb.prod.zone.month$ZoneName<- factor(gasbb.prod.zone.month$ZoneName, 
                                   levels= (c( 
                                     'Sydney',
                                     'Ballera',
                                     'Moomba','Victoria',
                                     'Port Campbell',
                                     'Gippsland',
                                     'Roma'
                                   )), ordered=TRUE)

gasbb.prod.zone.gld.month<-left_join( gasbb.prod.zone.month %>% subset(ZoneName=="Roma"), 
               gld, by=c("gasdate", "month", "year")) %>% 
  arrange(gasdate)
gasbb.prod.zone.gld.month$actualquantity.y[is.na(gasbb.prod.zone.gld.month$actualquantity.y)]<-0
gasbb.prod.zone.month$roma =0
gasbb.prod.zone.month$roma[gasbb.prod.zone.month$ZoneName=="Roma"] <-  gasbb.prod.zone.gld.month$actualquantity.y

# ggplot(gasbb.prod.zone.month, aes(gasdate, actualquantity))+
#   geom_area(aes(fill=ZoneName),position = "stack", size=.3, col="white")+
#   geom_line(data=gasbb.prod.zone.month %>% subset(ZoneName=="Roma"),aes(y=roma))+
#   scale_fill_manual(    values = c("plum", "grey80", "darkblue" ,"lightblue4",  "lightblue","firebrick3", "green4"))+
#   geom_line(data=gasbb.prod.zone.month %>% subset(ZoneName=="Roma"), 
#             aes(y=actualquantity-roma),  col="white", size=.3)+
#   geom_line(data=gasbb.prod.zone.month %>% subset(ZoneName=="Roma"), 
#             aes(y=actualquantity-roma*1.12), col="yellow", size=.3)

#production.month
ggplot(gasbb.prod.zone.month, aes(gasdate, actualquantity-roma*1.12))+
  geom_area(data=gasbb.prod.zone.month %>% subset(ZoneName=="Roma"),aes(y=-roma*1.12), fill="green4", alpha=.75)+
  geom_area(aes(fill=ZoneName),position = "stack",size=.02, col="white")+
  scale_fill_manual(    values = c("plum4", "grey70",
                                   "darkblue" ,"lightblue4",  "lightblue","firebrick3", "green4")) +
  labs (y = "supply balance - TJ/day", x=NULL, 
        subtitle=paste("Eastern gas market supply balance, NEM prices") ,caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/003") +
  theme(legend.position = "bottom")+
  geom_line(data=NEM.month %>% tail(-7), aes(date%>% set_month_day(15), RRP*30-3500), col="grey20", size=.23)+
  annotate("text", lubridate::ymd("2017-03-01"), -1000, label="Gladstone LNG supply\n+12% parasitic load", size=3, fontface =3,col="white" )+
  annotate("text", lubridate::ymd("2014-01-01"), 2300, label="Domestic supply", size=3 ,col="black",fontface =3 ) +
  #scale_y_continuous(sec.axis = sec_axis(~.*reproscir::tjday_to_mw(1)/1e3, "gigawatts  (energy equiv.)"))+
  scale_y_continuous(sec.axis = sec_axis(~(.+3500)/30, "NEM $/MWhour"))+
  
  theme(axis.text.y.right = element_text(color = "black"),
        axis.title.y= element_text(  color = "red3"),
        axis.text.y= element_text(  color = "red3"),                   
                             axis.title.y.right= element_text(angle = -90,   color = "black"))+
   coord_cartesian(ylim=c(-3500,2200))+
  scale_x_date(expand = c(0.005,0)) 
  
ggsave("~/Desktop/p001_03.png",  width=8, height=5.3) 
NEM.month

# ggplot(gasbb.prod.zone.month %>% subset(ZoneName %in% c("Moomba", "Gippsland")), aes(gasdate, actualquantity))+
#   geom_area(aes(fill=ZoneName),position = "stack", col="white", size=.3)+
#   scale_fill_manual(    values = c( "firebrick3" ,"darkblue"))
