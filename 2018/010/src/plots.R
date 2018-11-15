library(ggplot2)
# --------------------
# ggplot routines
#---------------------
plots <- function(nem.month   ) {

    nem.2005 = nem.month %>%
     subset(year==2005 & n=="total.corrected")  %>%
    dplyr::summarise(te=mean(te), date=mean(date))
  

  
  my.cols =c( "grey50","firebrick3" )
  my.sizes= c(.2,.3 )
  my.linetypes=c(2,1)
  
 p01<- ggplot(nem.month, aes(date, te*365/1e6, colour=n, size=n, linetype=n))+
    #geom_line(aes(y=te*365/1e6), col="grey60")+ 
    geom_line( )+
    labs(y="million tonnes CO2-e, annualised", x=NULL, 
         subtitle="NEM emissions, AEMO" ,
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
    scale_color_manual(values=my.cols)+
    scale_size_manual(values=my.sizes)+
      scale_linetype_manual(values=my.linetypes, guide=F)+
    theme(legend.position=c(.85,.85), legend.title=element_blank())
  
  
p02<- ggplot(nem.month, aes(date, te/nem.2005$te, col=n, size=n, linetype=n))+
    geom_line( )+
    scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
    geom_hline(yintercept = 1,  size=.25 ,linetype=2)+
  annotate("text", x=lubridate::ymd("2018-03-01") %>% as.POSIXct(), y=1.005, label= "2005 level", size=2)+
    labs(y="normalised to 2005 levels", x=NULL, 
         subtitle="NEM emissions, AEMO" ,
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010"
    )+
    scale_color_manual(values=my.cols)+
    scale_size_manual(values=my.sizes)+
  scale_linetype_manual(values=my.linetypes )+
  theme(legend.position=c(.85,.85), legend.title=element_blank())
  

return (list(p1=p01, p2=p02  ))
}
