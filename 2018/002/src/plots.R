library(ggplot2)

# --------------------
# ggplot routines
#---------------------
plots<- function(QLD.month) {

p01<-  ggplot2::ggplot(QLD.month  , aes(date, TOTALDEMAND/1000))+ 
  geom_smooth(  size=0, span=.25,  fill="red3",alpha=.1)+ 
  geom_line(data=lng , aes(y=tonnes/1e6/mdays*365/14 +5.2), size=.25  )+
  geom_point(data=lng , aes(y=tonnes/1e6/mdays*365/14 +5.2), size=.75  )+
  geom_smooth(data=lng , aes(y=tonnes/1e6/mdays*365/14+5.2), size=0, span=.25 ,alpha=.1)+ 
  scale_y_continuous(sec.axis = sec_axis(~(.-5.2)*14, "million tonnes - annualised") )+
  # coord_cartesian(ylim=c(0,8))+
  theme(axis.text.y.left = element_text(color = "red3"),
        axis.title.y.left= element_text(  color = "red3"),
        axis.title.y.right= element_text(angle = -90, hjust = 0, color = "black"))+
    geom_vline(xintercept = lubridate::ymd(c("2012-07-01", "2014-07-17")),
               col="red3", size=.2, linetype=2) +
    geom_vline(xintercept = lubridate::ymd(c("2017-04-01")), col="darkgreen", size=.2, linetype=2) +
    geom_text(data = data.frame(),aes(x=lubridate::ymd("2012-07-15"), y=7.2,
                                      label="start\nC-Tax"), hjust=-0.,col="Red3", size=3)+
    geom_text(data = data.frame(),aes(x=lubridate::ymd("2014-07-28"), y=7.2, 
                                      label="end\nC-Tax"), hjust=-0.,col="Red3", size=3)+
    geom_text(data = data.frame(),aes(x=lubridate::ymd("2017-04-19"), y=7.2,
                                      label="Hazelwood\nclosure"), hjust=-0.,col="darkgreen", size=3)+
    geom_line(size=.25, col="red3")+ 
    labs(subtitle="QLD electricity demand, Gladstone LNG exports", x=NULL, 
         y="gigawatts", caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/002")+
    theme(plot.caption=element_text(colour="grey80", size=8,hjust=1) )

return (list(p1=p01))
}