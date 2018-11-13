library(ggplot2)
# --------------------
# ggplot routines
#---------------------
plots <- function(merged.data,prb.monthly.data, roma.monthly.data,us.cbm.data,eia.us.ng.ann ) {

  p01 <- ggplot(merged.data %>% subset(date> lubridate::ymd("1990-01-01")), aes(date, val , col=region , linetype=region))+
    geom_line()+
    scale_color_manual(values=c("darkgreen", "black", "grey40", "red3"))+
    scale_linetype_manual(values=c(2,1,1,2))+
    geom_point( aes(size=factor(region)), show.legend = F)+
    scale_size_manual(values=c(2,0,0,2))+
    theme(legend.title = element_blank(), legend.position = c(.2,.8))+
    labs (x=NULL, y="methane production, TJ/day", 
          subtitle= "boom and bust in coal bed methane #2",
          caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/008"
    )
  
  p01a <- ggplot(merged.data %>% subset(region== "Powder River Basin, Wyoming" &date> lubridate::ymd("1995-01-01")), aes(date, val ))+
    geom_line() +
    labs (x=NULL, y="methane production, TJ/day", 
          subtitle= "boom and bust in coal bed methane #2a",
          caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/008"
    )+
    annotate("text", x= lubridate::ymd("1998-06-01"), y=1350, label="Powder River Basin\nWyoming")
# p01<- ggplot(prb.monthly.data, aes(date, prb.cbm*1e3/tj2cf  ))+
#   geom_line()+
#   labs (x=NULL, y="gas production, TJ/day", 
#         subtitle=paste0("total US (green dashed)\n","Powder River Basin, Wyoming", " (black)\nSan Juan Basin, New Mexico, Colarado, Utah (black dash)\nRoma, Queensland (red) "), 
#         caption=paste(data.source,"http://www.gasbb.com.au/Reports/Actual%20Flow.aspx")
#   )+
#   geom_line(data=head(tail(roma.monthly.data, -1),-1),  
#             aes(gasdate,actualquantity), colour="red2")+
#   # # geom_line(data=us.cbm.data, aes(x=as.Date(Date), y=TJ.d), linetype=2)+
#   # # geom_line(data=us.dry.data, aes(x=as.Date(date), y=value), colour="green3")+
#   geom_line(data=us.cbm.data , aes(x=date, y=cbm), linetype=2, col="green4")+
#   geom_line(data=us.cbm.data, aes(x=date, y=
#                                     rowSums( cbind (New.Mexico,Colorado,Utah ), na.rm=TRUE)*1e6*1e3/tj2cf/365), linetype=2, col="black")+
#   #geom_line(data=us.cbm.data, aes(x=date, y=Colorado*1e6*1e3/tj2cf/365), linetype=2, col="darkgreen")+
#   geom_point(data=us.cbm.data , aes(x=date, y=
#                                       rowSums( cbind (New.Mexico,Colorado,Utah ), na.rm=TRUE)*1e6*1e3/tj2cf/365),  size=3, col="white")+
#   geom_point(data=us.cbm.data, aes(x=date, y=
#                                      rowSums( cbind (New.Mexico,Colorado,Utah ), na.rm=TRUE)*1e6*1e3/tj2cf/365),  size=.75, col="black")+
#   scale_x_date(limits=ymd(c("1989-01-01","2017-08-01"))) 
# 

eia.us.ng.ann.gather<- tidyr::gather(eia.us.ng.ann[, c(1,3,4,5,6,7,8)], nom, value, -date )

eia.us.ng.ann.gather$value[eia.us.ng.ann.gather$nom =="shale" &  is.na(eia.us.ng.ann.gather$value)]<-0


p02a=ggplot(eia.us.ng.ann.gather %>% subset(date >lubridate::ymd("1985-01-01")), aes(date,value, fill=nom)) +
  geom_area(posit="fill", col="white", size=.2)+
  theme(legend.position = c(.28,.7), legend.direction = "horizontal", legend.title = element_blank()) +
  labs (x=NULL, y="methane production, % total", 
        subtitle= "boom and bust in coal bed methane #4",
        caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/008")+
  scale_y_continuous(labels = scales::percent_format(accuracy = 1))
        

p02= ggplot(eia.us.ng.ann.gather %>% subset(date >lubridate::ymd("1985-01-01")),
            aes(date,value*1e6/365/tj2cf, fill=nom)) +
  geom_area(posit="stack", col="white", size=.2)+
  theme(legend.position = c(.3,.85), legend.direction = "horizontal", legend.title = element_blank()) +
  labs (x=NULL, y="methane production, TJ/day", 
        subtitle= "boom and bust in coal bed methane #3",
        caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/008")
        

p03=ggplot(prb.monthly.data, aes(date,Total.Water.Bbls/1e6/cm2bbl ))+
  geom_line()+
  labs (x="date", y="total CBM water production, mill cubic metres month", subtitle="Powder River Basin" )



p03a=ggplot(prb.monthly.data, aes(date,Cum.Water.Bbls/1e6/cm2bbl ))+
  geom_line()+
  geom_hline(yintercept= c(syd.harbour/1e6,syd.harbour/1e6*2), linetype=2, size=.2)+
  annotate("text", x=lubridate::ymd("1990-01-01"), y= syd.harbour/1e6*1.05, label="1 Sydney Harbour")+
  annotate("text", x=lubridate::ymd("1990-01-01"), y= 2*syd.harbour/1e6*1.025, label="2 Sydney Harbours")+
  labs (x="date", y="cumulative water production, million cubic metres", subtitle="Powder River Basin" )


col2<- "firebrick3"; col1<- "royalblue4"; col3="grey30"
p03b =ggplot(prb.monthly.data %>% subset(date > lubridate::ymd("1990-01-01")), aes(date  ))+
  geom_line(aes(y = prb.cbm /1e6*30, col="Monthly gas production")  )+ 
  geom_line(aes(y = Cum.Water.Bbls/1e6/cm2bbl*.03333, col= "Cumulative water production"))+
  scale_y_continuous(sec.axis = sec_axis(~.*30, 
                                         name = "cumulative water production\nmillion cubic metres") )+
  scale_colour_manual(values = c(col2,col1))+
  labs(y = "methane production, bcf per month",
       subtitle= "boom and bust in coal bed methane #1",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/008"
  )+
  annotate("text", x= lubridate::ymd("2010-06-01"), y=5, label="Powder River Basin\nWyoming")+
#  theme(legend.position = c(0.3, 0.9), legend.title=element_blank())+
  geom_hline(yintercept= c(syd.harbour/1e6,syd.harbour/1e6*2)*.03333, linetype=2, size=.2 , col=col2)+
  annotate("text", x=lubridate::ymd("1998-01-01"), y= syd.harbour/1e6*.95*.03333, size=2,label="1 Sydney Harbour", col=col2)+
  annotate("text", x=lubridate::ymd("1998-01-01"), y= 2*syd.harbour/1e6*.975*.03333, size=2,label="2 Sydney Harbours", col=col2)+
  theme(legend.position = "None",
    axis.text.y.right = element_text(color = col2),
              axis.title.y= element_text(  color = col1),
              axis.text.y= element_text(  color = col1),                   
              axis.title.y.right= element_text(angle = -90,   color = col2))+
  xlim(c(lubridate::ymd("1995-01-01"), Sys.Date()))
        


# ggplot(merged.data, aes(date, prb/us/1e3)) +
#   geom_line()+   
#   scale_y_continuous(labels = scales::percent)+
#  # labs(x=NULL, y="% US gas production", subtitle="Powder River Basins CBM")+
#   geom_line(data=merged.annual.data, aes(dmy(paste0("30-06-",year)), US/us*1e3), linetype=2) +
#   geom_point(data=merged.annual.data, aes(dmy(paste0("30-06-",year)), US/us*1e3), size=2, col="white")+
#   geom_point(data=merged.annual.data, aes(dmy(paste0("30-06-",year)), US/us*1e3), size=1.3)+
#   labs(x=NULL, y="% US gas production", subtitle="Total US CBM (dashed)\nPowder River Basin (solid)")
# 

#print(roma.monthly.data)
# p02<- ggplot(merged.data, aes(date,prb*1e3/tj2cf  ))+
#   geom_line()+
#   labs (x=NULL, y="gas production, TJ/day"#, 
#        # subtitle=paste0("total US (green dashed)\n",region, " (black)\nSan Juan Basin, New Mexico, Colarado, Utah (black dash)\nRoma, Queensland (red) "), 
#        # caption=paste(data.source,"\nhttp://www.gasbb.com.au/Reports/Actual%20Flow.aspx")
#        )+
#   geom_line(data= roma.monthly.data  ,  
#             aes(gasdate,actualquantity), colour="red2")+
#   # geom_line(data=us.cbm.data, aes(x=as.Date(Date), y=TJ.d), linetype=2)+
#   # geom_line(data=us.dry.data, aes(x=as.Date(date), y=value), colour="green3")+
#   geom_line(  aes(  y=us), linetype=2, col="green4")#+
#   # geom_line(data= , aes(x=as.Date(Date), y=
#   #                                   rowSums( cbind (New.Mexico,Colorado,Utah ), na.rm=TRUE)*1e6*1e3/tj2cf/365), linetype=2, col="black")+
#   # # geom_line(data=us.cbm.data, aes(x=as.Date(Date), y=Colorado*1e6*1e3/tj2cf/365), linetype=2, col="darkgreen")+
#   # geom_point(data=us.cbm.data , aes(x=as.Date(Date), y=
#   #                                     rowSums( cbind (New.Mexico,Colorado,Utah ), na.rm=TRUE)*1e6*1e3/tj2cf/365),  size=3, col="white")+
#   # geom_point(data=us.cbm.data, aes(x=as.Date(Date), y=
#   #                                    rowSums( cbind (New.Mexico,Colorado,Utah ), na.rm=TRUE)*1e6*1e3/tj2cf/365),  size=.75, col="black")+
#   # scale_x_date(limits=ymd(c("1989-01-01","2017-08-01"))) 
# 


return (list(p1=p01 , p1a=p01a, p2=p02, p2a=p02a, p3=p03, p3a=p03a, p3b=p03b ))
}