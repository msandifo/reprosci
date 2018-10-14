library(ggplot2)
parasitic.load.n = 1 + parasitic.load/100
# --------------------
# ggplot routines
#---------------------
plots <- function(NEM.month, gasbb.prod.zone.month) {
  names(gasbb.prod.zone.month) <- stringr::str_to_lower(names(gasbb.prod.zone.month))
  gasbb.prod.zone.month$zonename<- factor(gasbb.prod.zone.month$zonename, 
                                          levels= (c( 
                                            'Sydney',
                                            'Ballera',
                                            'Moomba','Victoria',
                                            'Port Campbell',
                                            'Gippsland',
                                            'Roma'
                                          )), ordered=TRUE)
  fill.cols <- c("plum4", "grey70", "darkblue" ,"lightblue4",  "lightblue","firebrick3", "green4")

 p01<- ggplot(gasbb.prod.zone.month  , aes(date, actualquantity-gladstone*parasitic.load.n))+
    geom_area(data=gasbb.prod.zone.month %>% subset(zonename=="Roma"),aes(y=-gladstone*parasitic.load.n), fill="green4", alpha=.75)+
    geom_area(aes(fill=zonename),position = "stack",size=.02, col="white")+
    scale_fill_manual(    values = fill.cols) +
    labs (y = "supply balance - TJ/day", x=NULL, 
          subtitle=paste("Eastern gas market supply balance, NEM prices") ,
          caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/003") +
    theme(legend.position = "bottom")+
    geom_line(data=NEM.month %>% tail(-6) %>% head(-1), aes(date%>% reproscir::set_month_day(15), VWP*30-3500), col="grey20", size=.23)+
    annotate("text", lubridate::ymd("2017-03-01"), -1000, label=paste0("Gladstone LNG supply\n+", parasitic.load, "% parasitic load"), size=3, fontface =3,col="white" )+
    annotate("text", lubridate::ymd("2014-01-01"), 2300, label="Domestic supply", size=3 ,col="black",fontface =3 ) +
    scale_y_continuous(sec.axis = sec_axis(~(.+3500)/30, "VWP - $/MWhour"))+
    
    theme(axis.text.y.right = element_text(color = "black"),
          axis.title.y= element_text(  color = "red3"),
          axis.text.y= element_text(  color = "red3"),                   
          axis.title.y.right= element_text(angle = -90,   color = "black"))+
    coord_cartesian(ylim=c(-3500,2200))+
    scale_x_date(expand = c(0.005,0)) 
  
 

 p02<- ggplot(gasbb.prod.zone.month  , aes(date, actualquantity))+
     geom_area(aes(fill=zonename),position = "stack",size=.02, col="white")+
   scale_fill_manual(    values = fill.cols) +
   labs (y = "supply balance - TJ/day", x=NULL, 
         subtitle=paste("Eastern gas market supply, NEM prices") ,
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/003") +
   theme(legend.position = "bottom")+
   geom_line(data=NEM.month %>% tail(-6) %>% head(-1), aes(date%>% reproscir::set_month_day(15), VWP*20 ), col="grey20", size=.23)+
    scale_y_continuous(sec.axis = sec_axis(~(.+0)/20, "VWP - $/MWhour"))+
   
   theme(axis.text.y.right = element_text(color = "black"),
         axis.title.y= element_text(  color = "red3"),
         axis.text.y= element_text(  color = "red3"),                   
         axis.title.y.right= element_text(angle = -90,   color = "black"))+
   coord_cartesian(ylim=c(0,5400))+
   scale_x_date(expand = c(0.005,0)) 
 

return (list(p1=p01, p2=p02))
}
