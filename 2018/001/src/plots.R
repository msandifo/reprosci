
# --------------------
# ggplot themes
#---------------------
plots<- function(lng=lng, NEM.month=NEM.month, NEM.year=NEM.year, gas, gas.use ) {
   
  (NEM.year %>% subset(year %in% c(2015,2017)))$RRP %>% diff() -> nem.diff.15.17.RRP
  message((NEM.year %>% subset(year %in% c(2015,2017)))$RRP )
  message( nem.diff.15.17.RRP)
  (NEM.year %>% subset(year %in% c(2017)))$TOTALDEMAND -> nem.17.TD
  message( nem.17.TD)
  nem.diff.bill.dollars <-nem.diff.15.17.RRP*nem.17.TD*24*365/1e9
  message( nem.diff.bill.dollars)
  
  # population data form world bank useing wbstats package
  pop<- wbstats::wb(country = c("AUS"), indicator = "SP.POP.TOTL", startdate = 2017, enddate = 2017)$value
  nem.diff.dollars.person<- nem.diff.bill.dollars/pop*1e9
  
  
  
  # --------------------
  # graphics routines
  # --------------------
  #ggplot(NEM.month, aes(date, RRP))+geom_line()
  
  
  
p01<-  ggplot(lng  , aes(date, tonnes/1e6/mdays*365))+ geom_line(data=NEM.month , aes(y=RRP/5 ), size=.3, col="red2" )+
    geom_smooth(data=NEM.month , aes(y=RRP/5), size=0, span=.25,  fill="red3",alpha=.1)+ 
    scale_y_continuous(sec.axis = sec_axis(~.*5, "NEM - $/MW hour") )+
    coord_cartesian(ylim=c(0,25))+
    theme(axis.text.y.right = element_text(color = "red3"),
          axis.title.y.right= element_text(angle = -90, hjust = 0, color = "red3"),
          legend.position="None")+
    #scale_size_manual(values=c(.3,.3,.4,.3))+
    geom_vline(xintercept = lubridate::ymd(c("2012-07-01", "2014-07-17")),
               col="red3", size=.2, linetype=2) +
    geom_vline(xintercept = lubridate::ymd(c("2017-04-01")), col="darkgreen", size=.2, linetype=2) +
    geom_text(data = data.frame(),aes(x=lubridate::ymd("2012-07-15"), y=25,
                                      label="start\nC-Tax"), hjust=-0.,col="Red3", size=3)+
    geom_text(data = data.frame(),aes(x=lubridate::ymd("2014-07-28"), y=25, 
                                      label="end\nC-Tax"), hjust=-0.,col="Red3", size=3)+
    geom_text(data = data.frame(),aes(x=lubridate::ymd("2017-04-19"), y=25,
                                      label="Hazelwood\nclosure"), hjust=-0.,col="darkgreen", size=3)+
    geom_label(data = data.frame(),aes(x=lubridate::ymd("2017-06-30"), y=5,
                                       label=paste0("2017 cf 2015\n+$",
                                                    round(nem.diff.15.17.RRP*nem.17.TD*24*365/1e9, 1),
                                                    " billion\n~ $", signif(nem.diff.dollars.person,2), 
                                                    " per cap.")), 
               col="Red3", size=4)+
    geom_smooth(data=NEM.month %>%subset(year == 2015 | year==2017) ,
                aes(y=RRP/5, group=year), method="lm", formula=y~1, size=2.,  colour="white",  se=F)+
    geom_smooth(data=NEM.month %>%subset(year == 2015 | year==2017) ,
                aes(y=RRP/5, group=year), method="lm", formula=y~1, size=.7,  colour="red3",  se=F)+
    geom_smooth(size=0, span=.35)+
    geom_line(size=.15)+ 
    geom_point(size=1.25, colour="white")+
    geom_point(size=.75)+
    labs(subtitle="Gladstone LNG exports, NEM prices", x=NULL, 
         y="million tonnes - annualised", caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/001")+
    theme(plot.caption=element_text(colour="grey80", size=8,hjust=1) )
  


p02 <-ggplot(gas, aes(date, mw/1000 ))+geom_area(aes( fill=gas.type), alpha=.85,col="white", size=.2,position = "stack")+
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
  
p02 <- p02  +geom_line(data=NEM.month %>% subset(date< max( gas$date)+months(1)), aes(y=RRP*20/1000))+
    coord_cartesian(ylim=c(0,3.200))+
    scale_y_continuous(sec.axis = sec_axis(~.*.05*1000, "NEM - $/MW hour") )+
    theme(axis.text.y.left = element_text(color = "red3"),
          axis.title.y.left= element_text(  color = "red3"),
          axis.title.y.right= element_text(angle = -90, hjust = 0, color = "black"))+
    labs(subtitle="NEM gas generation, prices", x=NULL, 
         y="gigawatts", caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/001")+
    theme(plot.caption=element_text(colour="grey80", size=8,hjust=1) )



p03<-  ggplot(gas, aes(date, mw/1000 ))+ geom_area(aes( fill=gas.type), alpha=.85,col="white", size=.2,position = "fill")+
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
    scale_y_continuous(labels = scales::percent, breaks = seq(0,1,by=0.1))+
    labs(subtitle="NEM gas generation, thermal efficiency", x=NULL, 
         y=NULL, caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/001")
  
  return (list(p1=p01,p2=p02,p3=p03))
}