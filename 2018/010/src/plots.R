library(ggplot2)
# --------------------
# ggplot routines
#---------------------
plots <- function(nem.month , nem.year,gas.con, gas.prod ) {

    nem.2005 = nem.month %>%
     subset(year==2005 & n=="total.corrected")  %>%
    dplyr::summarise(te=mean(te), date=mean(date))
  
      nem.2017 = nem.month %>%
      subset(year==2017 & n=="total.corrected")  %>%
      dplyr::summarise(te=mean(te), date=mean(date))
    
    nem.diff  <-(nem.2005$te-nem.2017$te)*365/1e6
    nem.year$diffs  <-(nem.2005$te-nem.year$te)*365/1e6
    print(nem.year$diffs)
    my.cols =c( "grey40","firebrick4" )
    
  
  my.cols =c( "grey50","firebrick3" )
  my.sizes= c(.2,.3 )
  my.linetypes=c(2,1)
  
  my.col<-"darksalmon"
 p01<- ggplot(nem.month, aes(date, te*365/1e6, colour=n, size=n, linetype=n))+
    #geom_line(aes(y=te*365/1e6), col="grey60")+ 
   geom_smooth(data=nem.month %>% subset(n=="total.corrected") %>% dplyr::ungroup() %>%dplyr::mutate(year=factor(year)),
               aes(group=year), size=1,method="lm", formula=y~1, colour=  my.col, show.legend = F, se=F)+
   geom_line( )+
    labs(y="million tonnes CO2-e, annualised", x=NULL, 
         subtitle="NEM emissions, AEMO" ,
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
    scale_color_manual(values=my.cols)+
    scale_size_manual(values=my.sizes)+
      scale_linetype_manual(values=my.linetypes, guide=F)+
    theme(legend.position=c(.85,.85), legend.title=element_blank())

 
 p01a<- ggplot(nem.month, aes(date, (te-nem.2005$te)*365/1e6, colour=n, size=n, linetype=n))+
   #geom_line(aes(y=te*365/1e6), col="grey60")+ 
   geom_smooth(data=nem.month %>% subset(n=="total.corrected") %>% dplyr::ungroup() %>%dplyr::mutate(year=factor(year)),
               aes(group=year), size=1,method="lm", formula=y~1, colour=  my.col, show.legend = F, se=F)+
   geom_line( )+
   labs(y="million tonnes CO2-e, annualised cf. 2005", x=NULL, 
        subtitle="NEM emissions cf. 2005, AEMO" ,
        caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
   geom_label(data= nem.year %>% subset(n=="total.corrected"), aes(x= date+ months(0), y=-40, label = signif(round(diffs,1),2) ),
               label.size=0,size=2, col="black")+
   
   # annotate("text", x=lubridate::ymd("2017-06-01") %>% as.POSIXct(), y= -10, 
   #          label= paste("2017 down",round( nem.diff,2), "\nmill.tonnes"), size=2)+
   scale_color_manual(values=my.cols)+
   scale_size_manual(values=my.sizes)+
   scale_linetype_manual(values=my.linetypes, guide=F)+
   theme(legend.position=c(.85,.85), legend.title=element_blank())
 
  
p02<- ggplot(nem.month, aes(date, te/nem.2005$te, col=n, size=n, linetype=n))+
  geom_smooth(data=nem.month %>% subset(n=="total.corrected") %>% dplyr::ungroup() %>%dplyr::mutate(year=factor(year)),
              aes(group=year), size=1,method="lm", formula=y~1, colour=  my.col, show.legend = F, se=F)+
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
  

growth.rate <- c(round(lm(value/gas.con.2005 ~year, gas.con %>% subset(year<=2005  &year>1980))$coef[2]*100,1),
                 round(lm(value/gas.con.2005 ~year, gas.con %>% subset(year>=2005))$coef[2]*100,1))
gas.con.2005 <-gas.con$value[gas.con$year==2005]
p03<- ggplot(gas.con %>% subset(year>1980), aes(year, value/gas.con.2005))+
  geom_smooth( data= gas.con %>% subset(year>1980 & year<=2005), se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
  geom_smooth( data= gas.con %>% subset(year> 2004), se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
  geom_line(size=.3 ) +
  geom_point(colour="white", size=2 ) +
  geom_point(size=1.5)+
  scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
  geom_hline(yintercept = 1,  size=.25 ,linetype=2)+
  annotate("text", x=2016.7, y=1.03, label= "2005 level", size=3)+
  annotate("text", x=1992, y=.85, label= paste0(growth.rate[1], "% p.a."), size=4)+
  annotate("text", x=2013, y=1.4, label= paste0(growth.rate[2], "% p.a."), size=4)+
  labs(y="normalised to 2005 levels", x=NULL, 
       subtitle="Australian gas consumption, BP Statistical review, 2018",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")

gas.prod.2005 <-gas.prod$value[gas.prod$year==2005]

gas.lng <- gas.con%>% subset(year>1980)
gas.lng$value <- (gas.prod %>% subset(year>1980))$value - (gas.con %>% subset(year>1980))$value 
gas.lng.2005 <-gas.lng$value[gas.lng$year==2005]

p04<-ggplot(gas.lng%>% subset(year>1980), aes(year, (value-gas.lng.2005 )*.735 ))+
  # geom_smooth( data= gas.con %>% subset(year>1980 & year<=2005), fullrange=F, se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
  # geom_smooth( data= gas.con %>% subset(year> 2004), se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
  geom_line(size=.3 ) +
  geom_line(data=gas.lng %>% subset(year>=2005), size=.7 , col="red3", aes(y=(value-gas.lng.2005 )*.735*.3 )) +
  geom_point(colour="white", size=2 ) +
  geom_point(size=1.5)+
  # scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
  geom_hline(yintercept = 0,  size=.25 ,linetype=2)+
  annotate("text", x=1995, y=40, label= "2017-2005 LNG processing emissions - estimated", size=4, col="red3")+
  annotate("text", x=1995, y=37, label= paste(signif((tail(gas.lng$value,1)-gas.lng.2005 )*.735*.3,2) ,"mill.tonnes CO2-e"), size=4, col="red3")+
  # annotate("text", x=1992, y=-3, label= paste0(growth.rate[1], "% p.a."), size=4)+
  # annotate("text", x=2013, y=7, label= paste0(growth.rate[2], "% p.a."), size=4)+
  labs(y="million tonnes LNG,cf. 2005 levels", x=NULL, 
       subtitle="Australian gas exports, BP Statistical review, 2018",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
  xlim(c(1987,2017))


return (list(p1=p01,p1a=p01a, p2=p02, p3=p03  , p4=p04 ))
}
