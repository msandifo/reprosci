library(ggplot2)

# --------------------
# ggplot routines
#---------------------
plots <- function(NEM.month, gasbb.prod.zone.month) {

#  print(head(gasbb ))
  #ggplot(gasbb %>%  reproscir::group_gasbb(), aes(gasdate, actualquantity* reproscir::tjday_to_mw()))+geom_line()
 p01<- ggplot(gasbb.prod.zone.month, aes(gasdate, actualquantity-roma*1.12))+
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
  


return (list(p1=p01))
}