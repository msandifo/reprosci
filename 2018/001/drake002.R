gas.use <-data.table::fread("/Volumes/data/Dropbox/msandifo/documents/programming/r/twitter/2018/001/data/gas_generation.csv")
names(gas.use) <- stringr::str_to_lower(names(gas.use))
gas <- tidyr::gather(gas.use, key,value, -year, -month) %>% 
  dplyr::mutate(date = lubridate::ymd(paste0(year,"-",month,"-15")) ,
                mdays = lubridate::days_in_month(date),
                mw= value*1e3/(mdays*24)*12, gas.type= stringr::str_remove_all(key, "gas_"))

NEM.month<-readd(NEM.month)

p1<-ggplot(gas, aes(date, mw/1000 ))+geom_area(aes( fill=gas.type), alpha=.85,col="white", size=.2,position = "stack")+
  geom_vline(xintercept = lubridate::ymd(c("2012-07-01", "2014-07-17")),
             col="red4", size=.2, linetype=2) +
  geom_vline(xintercept = lubridate::ymd(c("2017-04-01")), col="darkgreen", size=.2, linetype=2) +
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2012-07-15"), y=3.200 ,
                                    label="start\nC-Tax"), hjust=-0.,col="Red4", size=3)+
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2014-07-28"), y=3.200 , 
                                    label="end\nC-Tax"), hjust=-0.,col="Red4", size=3)+
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2017-04-19"), y=3.200,
                                    label="Hazelwood\nclosure"), hjust=-0.,col="darkgreen", size=3)+
  theme(legend.position = "bottom")
 
p1 +geom_line(data=NEM.month %>% subset(date< max( gas$date)+months(1)), aes(y=RRP*20/1000))+
  coord_cartesian(ylim=c(0,3.200))+
  scale_y_continuous(sec.axis = sec_axis(~.*.05*1000, "NEM - $/MW hour") )+
   theme(axis.text.y.left = element_text(color = "red3"),
        axis.title.y.left= element_text(  color = "red3"),
        axis.title.y.right= element_text(angle = -90, hjust = 0, color = "black"))+
  labs(subtitle="NEM gas generation, prices", x=NULL, 
       y="gigawatts", caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/twitter/blob/master/001/drake001.R")+
  theme(plot.caption=element_text(colour="grey80", size=8,hjust=1) )

ggsave("/Volumes/data/Dropbox/msandifo/documents/programming/r/twitter/2018/001/figs/ms002.png", width=8, height=5) 

gas.use$date = lubridate::ymd(paste0(gas.use$year,"-",gas.use$month,"-15"))
gas.use$sum = rowSums(gas.use[, 3:5])
gas.use$efficiencyLower =(gas.use$gas_ccgt*.45 +gas.use$gas_ocgt*.3 +gas.use$gas_steam*.3 )/gas.use$sum
gas.use$efficiencyUpper =(gas.use$gas_ccgt*.5 +gas.use$gas_ocgt*.35 +gas.use$gas_steam*.35 )/gas.use$sum
#30-35% for steam (i.e. Torrens & Northern), 45%-50% for CCGT, and 30-35% for OCGT. 


ggplot(gas, aes(date, mw/1000 ))+geom_area(aes( fill=gas.type), alpha=.85,col="white", size=.2,position = "fill")+
  geom_vline(xintercept = lubridate::ymd(c("2012-07-01", "2014-07-17")),
             col="red4", size=.2, linetype=2) +
  geom_vline(xintercept = lubridate::ymd(c("2017-04-01")), col="darkgreen", size=.2, linetype=2) +
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2012-07-15"), y=.900 ,
                                    label="start\nC-Tax"), hjust=-0.,col="Red4", size=3)+
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2014-07-28"), y=.900 , 
                                    label="end\nC-Tax"), hjust=-0.,col="Red4", size=3)+
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2017-04-19"), y=.900,
                                    label="Hazelwood\nclosure"), hjust=-0.,col="darkgreen", size=3)+
  theme(legend.position = "bottom")+
  geom_line(data=gas.use, aes(y=efficiencyLower), size=.2)+
  geom_line(data=gas.use, aes(y=efficiencyUpper), size=.2)+
  coord_cartesian(ylim=c(0,.6))+
  labs(subtitle="NEM gas generation, thermal efficiency", x=NULL, 
       y="%", caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/twitter/blob/master/001/drake001.R")
  


