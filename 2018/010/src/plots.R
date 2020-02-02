library(ggplot2)
# --------------------
# ggplot routines
#---------------------
plots <- function(nem.month, nem.quarter, nem.year, gas.con, gas.prod, gas.con.t, oil.con , coal.con, emissions, ob, oil.balance) {

    nem.2005 = nem.month %>%
     subset(year==2005 & n=="total.corrected")  %>%
    dplyr::summarise(te=mean(te), date=mean(date))
  
    nem.q.2005 = nem.quarter %>%
      subset(year==2005 & n=="total.corrected")  %>%
      dplyr::summarise(te=mean(te), date=mean(date))
    
    nem.2018 = nem.month %>%
      subset(year==2018 & n=="total.corrected")  %>%
      dplyr::summarise(te=mean(te), date=mean(date))
    
    nem.diff  <-(nem.2005$te-nem.2018$te)*365/1e6
    nem.year$diffs  <-(nem.2005$te-nem.year$te)*365/1e6
  #  print(nem.year$diffs)
    my.cols =c( "grey40","firebrick4" )
    
   gas.con.2005 = gas.con$value[gas.con$year==2005]  
    
  my.cols =c( "grey50","firebrick3" )
  my.cols4 =c(  "grey50",  "green4" ,"brown","firebrick2")
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
        subtitle="A ministerial energy primer #1a\nNEM emissions cf. 2005, AEMO" ,
        caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
   geom_label(data= nem.year %>% subset(n=="total.corrected"), aes(x= date+ months(0), y=-40, label = signif(round(diffs,1),2) ),
               label.size=0,size=2, col="black")+
   
   # annotate("text", x=lubridate::ymd("2018-06-01") %>% as.POSIXct(), y= -10, 
   #          label= paste("2018 down",round( nem.diff,2), "\nmill.tonnes"), size=2)+
   scale_color_manual(values=my.cols)+
   scale_size_manual(values=my.sizes)+
   scale_linetype_manual(values=my.linetypes, guide=F)+
   theme(legend.position=c(.85,.85), legend.title=element_blank())
 
 
 nem.year.te.2005 = nem.year$te[nem.year$year==2005 &nem.year$n=="total.corrected" ]
 nem.year.te.2018 = nem.year$te[nem.year$year==2018 &nem.year$n=="total.corrected" ]
 #(nem.year.te.2005-nem.year.te.2018)*365/1e6
 
 
 p01b <- ggplot(nem.year %>% subset(year>2000 & year<2019 & n=="total.corrected"), 
                aes(year, (te- nem.year.te.2005)*365/1e6, col=time, fill=time))+
   #  geom_smooth( data=nem.year %>% subset(year>2007 & n=="total.corrected"), se=T, method="lm", size=.2,   alpha=.1 ) +
   # geom_smooth( data=nem.year %>% subset(year<=2008 & n=="total.corrected"), se=T, method="lm", size=.2,   alpha=.1 ) +
   #  geom_smooth( data= oil.con %>% subset(year>1980 & year<2005), se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
   # geom_smooth( data= oil.con %>% subset(year> 2004), se=T, colour="white", fill="darksalmon", size=.2, method="lm", alpha=.3) +
   geom_line(size=.3 ) +
   geom_point(colour="white", size=2 ) +
   geom_point(size=1.5)  +
   # annotate("text", x=1995, y=8, label= "oil consumption added\n ", size=6, col="red3")+
   annotate("text", x=2016, y=-5, label= paste("electrical power system\n CO2-e emissions reduced by \n~", 
                                               signif((nem.year.te.2005 -nem.year.te.2018)*365/1e6,2) ,"million tonnes \n in 2018  cf. 2005*"), 
            fontface =3, size=4, col=my.cols[2])+
   annotate("text", x=2004, y=-25, label= "*due to both decarbonisation and demand destruction", fontface=3, size=2.5, col="grey70")+
   
   #  scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
   geom_hline(yintercept = 0,  size=.25 ,linetype=2)+
   # annotate("text", x=2016.7, y=.4, label= "2005 level", size=3)+
   # annotate("text", x=1989, y=-4, label= paste0(oil.growth.rate[1], "% p.a."), size=4, col=my.cols[1])+
   # annotate("text", x=2013, y=5, label= paste0(oil.growth.rate[2], "% p.a."), size=4, col=my.cols[2])+
   scale_colour_manual(values=rev(my.cols))+
   scale_fill_manual(values=rev(my.cols))+
   labs(y="million tonnes Co2-e, cf. 2005", x=NULL, 
        subtitle="A ministerial energy primer #1b\nNEM electrical power generation, AEMO",
        caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
   theme(legend.position="None")
 
# print(tail(nem.quarter))
  
 
 nem.quarter$quarter<- factor(nem.quarter$quarter)
 p01c <- ggplot(nem.quarter %>% subset(year>2000 & year<2019 & n=="total.corrected"), 
                aes(lubridate::decimal_date(date), te /1e6 , col=quarter, shape=quarter))+
   #  geom_smooth( data=nem.year %>% subset(year>2007 & n=="total.corrected"), se=T, method="lm", size=.2,   alpha=.1 ) +
   # geom_smooth( data=nem.year %>% subset(year<=2008 & n=="total.corrected"), se=T, method="lm", size=.2,   alpha=.1 ) +
   #  geom_smooth( data= oil.con %>% subset(year>1980 & year<2005), se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
   # geom_smooth( data= oil.con %>% subset(year> 2004), se=T, colour="white", fill="darksalmon", size=.2, method="lm", alpha=.3) +
   geom_line(size=.3 ) +
   geom_point(colour="white", size=2 ) +
   geom_point(size=1.5)  +
   # annotate("text", x=1995, y=8, label= "oil consumption added\n ", size=6, col="red3")+
   # annotate("text", x=2016, y=-5, label= paste("electrical power system\n CO2-e emissions reduced by \n~", 
   #                                             signif((nem.year.te.2005 -nem.year.te.2018)*365/1e6,2) ,"million tonnes \n in 2018  cf. 2005*"), 
   #          fontface =3, size=4, col=my.cols[2])+
   # annotate("text", x=2004, y=-25, label= "*due to both decarbonisation and demand destruction", fontface=3, size=2.5, col="grey70")+
   
   #  scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
  # geom_hline(yintercept = 0,  size=.25 ,linetype=2)+
   # annotate("text", x=2016.7, y=.4, label= "2005 level", size=3)+
   # annotate("text", x=1989, y=-4, label= paste0(oil.growth.rate[1], "% p.a."), size=4, col=my.cols[1])+
   # annotate("text", x=2013, y=5, label= paste0(oil.growth.rate[2], "% p.a."), size=4, col=my.cols[2])+
   scale_colour_manual(values=rev(my.cols4))+
   scale_fill_manual(values=rev(my.cols4))+
   labs(y="million tonnes Co2-e per quarter, NEM", x=NULL, 
        subtitle="A ministerial energy primer #1c\nNEM emissions by quarter, AEMO",
        caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
   theme(legend.position=c(.85,.85))
 
 ( p01c )
 
p02<- ggplot(nem.month, aes(date, te/nem.2005$te, col=n, size=n, linetype=n))+
  geom_smooth(data=nem.month %>% subset(n=="total.corrected") %>% dplyr::ungroup() %>%dplyr::mutate(year=factor(year)),
              aes(group=year), size=1,method="lm", formula=y~1, colour=  my.col, show.legend = F, se=F)+
  geom_line( )+
    scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
    geom_hline(yintercept = 1,  size=.25 ,linetype=2)+
   annotate("text", x=lubridate::ymd("2018-03-01") %>% as.POSIXct(), y=1.005, label= "2005 level", size=2)+
    labs(y="normalised to 2005 levels", x=NULL, 
         subtitle="A ministerial energy primer #2\nNEM emissions, AEMO" ,
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
       subtitle="A ministerial energy primer #3\nAustralian gas consumption, BP Statistical review, 2018",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")


gas.con.t.2005 <-gas.con.t$value[gas.con.t$year==2005]
growth.rate.t <- c(round(lm(value/gas.con.t.2005 ~year, gas.con.t %>% subset(year<=2005  &year>1980))$coef[2]*100,1),
                   round(lm(value/gas.con.t.2005 ~year, gas.con.t %>% subset(year>=2005))$coef[2]*100,1))


mtogas2co2e= 2.35

p03a<-ggplot(gas.con.t %>% subset(year>1980), aes(year, value- gas.con.t.2005, col=time, fill=time))+
  geom_smooth(  se=T,   size=.2, method="lm", alpha=.3) +
  #  geom_smooth( data= oil.con %>% subset(year>1980 & year<2005), se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
  # geom_smooth( data= oil.con %>% subset(year> 2004), se=T, colour="white", fill="darksalmon", size=.2, method="lm", alpha=.3) +
  geom_line(size=.3 ) +
  geom_point(colour="white", size=2 ) +
  geom_point(size=1.5)+
  scale_y_continuous(sec.axis = sec_axis(~.*mtogas2co2e, "CO2 emissions - million tonnes, cf. 2005") )+
  theme(axis.text.y.right = element_text(color = my.cols[2]),
        
        axis.title.y.right= element_text(angle = -90, hjust = 1, color = my.cols[2]))+
  # annotate("text", x=1995, y=8, label= "oil consumption added\n ", size=6, col="red3")+
  annotate("text", x=2006, y=12, label= paste("gas consumption added\n~", signif((tail(gas.con.t$value,1)-gas.con.t.2005 )*mtogas2co2e,2) ,"million tonnes CO2-e\n in 2018  cf. 2005"), 
           fontface =3, size=4, col=my.cols[2])+
  annotate("text", x=2011, y=-11, label= paste("assuming,",mtogas2co2e,"tonnes CO2\nfor every  tonne oil equiv. gas"), fontface=3, size=2.5, col="grey70")+
  
  #  scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
  geom_hline(yintercept = 0,  size=.25 ,linetype=2)+
  # annotate("text", x=2016.7, y=.4, label= "2005 level", size=3)+
  annotate("text", x=1989, y=-4, label= paste0( growth.rate.t[1], "% p.a."), size=4, col=my.cols[1])+
  annotate("text", x=2013, y=8, label= paste0( growth.rate.t[2], "% p.a."), size=4, col=my.cols[2])+
  scale_colour_manual(values=rev(my.cols))+
  scale_fill_manual(values=rev(my.cols))+
  labs(y="gas consumption - mtoe, cf. 2005", x=NULL, 
       subtitle="A ministerial energy primer #3a\nAustralian gas consumption, BP Statistical Review 2018",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
  theme(legend.position="None")

 
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
  annotate("text", x=1995, y=40, label= "2018-2005 LNG processing emissions - estimated", size=4, col="red3")+
  annotate("text", x=1995, y=37, label= paste(signif((tail(gas.lng$value,1)-gas.lng.2005 )*.735*.3,2) ,"mill.tonnes CO2-e"), size=4, col="red3")+
  # annotate("text", x=1992, y=-3, label= paste0(growth.rate[1], "% p.a."), size=4)+
  # annotate("text", x=2013, y=7, label= paste0(growth.rate[2], "% p.a."), size=4)+
  labs(y="million tonnes LNG,cf. 2005 levels", x=NULL, 
       subtitle="A ministerial energy primer #4\nAustralian gas exports, BP Statistical review, 2018",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
  xlim(c(1987,2018))


oil.con.2005 <-oil.con$value[oil.con$year==2005]
oil.growth.rate <- c(round(lm(value/oil.con.2005 ~year, oil.con %>% subset(year<=2005  &year>1980))$coef[2]*100,1),
                     round(lm(value/oil.con.2005 ~year, oil.con %>% subset(year>=2005))$coef[2]*100,1))

mto2co2e= 3.07
p05<-ggplot(oil.con %>% subset(year>1980), aes(year, value- oil.con.2005, col=time, fill=time))+
  geom_smooth(  se=T,   size=.2, method="lm", alpha=.3) +
  #  geom_smooth( data= oil.con %>% subset(year>1980 & year<2005), se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
  # geom_smooth( data= oil.con %>% subset(year> 2004), se=T, colour="white", fill="darksalmon", size=.2, method="lm", alpha=.3) +
  geom_line(size=.3 ) +
  geom_point(colour="white", size=2 ) +
  geom_point(size=1.5)+
  scale_y_continuous(sec.axis = sec_axis(~.*mto2co2e, "CO2 emissions - million tonnes, cf. 2005") )+
  theme(axis.text.y.right = element_text(color = my.cols[2]),
        
        axis.title.y.right= element_text(angle = -90, hjust = 1, color = my.cols[2]))+
  # annotate("text", x=1995, y=8, label= "oil consumption added\n ", size=6, col="red3")+
  annotate("text", x=2002, y=7, label= paste("oil consumption added\n~", signif((tail(oil.con$value,1)-oil.con.2005 )*mto2co2e,2) ,"million tonnes CO2-e\n in 2018  cf. 2005"), 
           fontface =3, size=4, col=my.cols[2])+
  annotate("text", x=2011, y=-11, label= paste("assuming",mto2co2e,"tonnes CO2\nfor per tonne oil equiv."), fontface=3, size=2.5, col="grey70")+
  
  #  scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
  geom_hline(yintercept = 0,  size=.25 ,linetype=2)+
  # annotate("text", x=2016.7, y=.4, label= "2005 level", size=3)+
  annotate("text", x=1989, y=-4, label= paste0(oil.growth.rate[1], "% p.a."), size=4, col=my.cols[1])+
  annotate("text", x=2013, y=5, label= paste0(oil.growth.rate[2], "% p.a."), size=4, col=my.cols[2])+
  scale_colour_manual(values=rev(my.cols))+
  scale_fill_manual(values=rev(my.cols))+
  labs(y="oil consumption - mtoe, cf. 2005", x=NULL, 
       subtitle="A ministerial energy primer #5\nAustralian oil consumption, BP Statistical Review 2018",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
  theme(legend.position="None")

ob1 = tail(ob,1) # %>% tidyr::pivot_longer(cols=c(value.x, value.y))
ob.p =  round((ob1$value.x-ob1$value.y)/ob1$value.x * 100, 0)

model.prod <- lm(  value~ year, data=oil.balance %>% subset(name == "production" & year>=2000) )
model.cons<- lm(  value ~year,  data=oil.balance %>% subset(name == "consumption" & year>=2000) )
xseq <- 2000:2033
pred.prod  <- model.prod$coefficients[1] + xseq*model.prod$coefficients[2]
pred.prod[pred.prod<0]<-0
pred.cons  <- model.cons$coefficients[1] + xseq*model.cons$coefficients[2]
pred <- data.frame(year=xseq, consumption=pred.cons, production=pred.prod) %>% tidyr::pivot_longer(cols=c(consumption, production))

p05a<-ggplot(oil.balance %>% subset(name != "import"), aes(year,value, col=name))+
  geom_line(data=pred, linetype=2)+
  geom_point(data= pred %>%subset(year==2030), col="white", size=2.5 ) +
  geom_point(data= pred%>%subset(year==2030), size=2. ) +
  
  geom_line(size=1., aes(group=name), colour="white") +
  geom_line(size=.5) +
  geom_point(data= oil.balance %>% subset(name != "import" & year==2018), col="white", size=2.5 ) +
  geom_point(data= oil.balance %>% subset(name != "import" & year==2018), size=2. ) +
  labs(x=NULL, y="million tonnes per year",
       subtitle= #"A ministerial energy primer #5a\n
       "Australian oil production/consumption trends,\nBP Statistical Review 2019",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
  theme(legend.position = c(.15,.83), legend.title = element_blank() )+
  # geom_segment(data=ob1, aes(xend=year, y=value.x-1, yend= value.y+1), col="red2", linetype=1, size=.23,
  #              arrow = arrow(length = unit(0.04, "npc")))+
  # geom_segment(data=ob1, aes(xend=year, y=value.y+1, yend= value.x-1), col="red2", linetype=1, size=.23,
  #              arrow = arrow(length = unit(0.04, "npc")))+
  # geom_segment(data=ob1, aes(xend=year, yend=value.y-1, y= 0), col="blue1", linetype=1, size=.23,
  #              arrow = arrow(length = unit(0.04, "npc")))+
  annotate("text", x= 2018, y=34, label= paste0("2018\n net oil imports\n~ ", ob.p, "%"), col="red3", size=3.2)+
  annotate("text", x= 2030, y=34, label= paste0("2030 (trend)\nnet oil imports\n~ ", "100", "%"), col="grey20", size=3.2)+
  # stat_smooth(data=oil.balance %>% subset(name != "import" & year>1999), method="lm",
  #             se=F, fullrange=T, size=.5, linetype=2 )+
  xlim(c(1965,2033))

coal.con.2005 <-coal.con$value[coal.con$year==2005]
coal.growth.rate <- c(round(lm(value/coal.con.2005 ~year, coal.con %>% subset(year<=2005  &year>1980))$coef[2]*100,1),
                      round(lm(value/coal.con.2005 ~year, coal.con %>% subset(year>=2005))$coef[2]*100,1))

mtoc2co2e= 3.96

p06<-ggplot(coal.con %>% subset(year>1980), aes(year, value- coal.con.2005, col=time, fill=time))+
  geom_smooth(  se=T,   size=.2, method="lm", alpha=.3) +
  #  geom_smooth( data= oil.con %>% subset(year>1980 & year<2005), se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
  # geom_smooth( data= oil.con %>% subset(year> 2004), se=T, colour="white", fill="darksalmon", size=.2, method="lm", alpha=.3) +
  geom_line(size=.3 ) +
  geom_point(colour="white", size=2 ) +
  geom_point(size=1.5)+
  scale_y_continuous(sec.axis = sec_axis(~.*mtoc2co2e, "CO2 emissions - million tonnes, cf. 2005") )+
  theme(axis.text.y.right = element_text(color = my.cols[2]),
        
        axis.title.y.right= element_text(angle = -90, hjust = 1, color = my.cols[2]))+
  # annotate("text", x=1995, y=8, label= "oil consumption added\n ", size=6, col="red3")+
  annotate("text", x=2006, y=-12, label= paste("coal consumption removed\n~", signif(abs(tail(coal.con$value,1)-coal.con.2005 )*mtoc2co2e,2) ,"million tonnes CO2-e\n in 2018  cf. 2005"), 
           fontface =3, size=4, col=my.cols[2])+
  annotate("text", x=2011, y=-24, label= paste("assuming", mtoc2co2e,"tonnes CO2\nfor every oil equiv. tonne coal"), fontface=3, size=2.5, col="grey70")+
  
  #  scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
  geom_hline(yintercept = 0,  size=.25 ,linetype=2)+
  # annotate("text", x=2016.7, y=.4, label= "2005 level", size=3)+
  annotate("text", x=1989, y=-11, label= paste0(coal.growth.rate[1], "% p.a."), size=4, col=my.cols[1])+
  annotate("text", x=2014, y=-2, label= paste0(coal.growth.rate[2], "% p.a."), size=4, col=my.cols[2])+
  scale_colour_manual(values=rev(my.cols))+
  scale_fill_manual(values=rev(my.cols))+
  labs(y="coal consumption - mtoe, cf. 2005", x=NULL, 
       subtitle="A ministerial energy primer #6\nAustralian coal consumption, BP Statistical Review 2018",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
  theme(legend.position="None")

emissions.2005 <-emissions$value[emissions$year==2005]
emissions.2018 <-emissions$value[emissions$year==2018]
coal.growth.rate <- c(round(lm(value/emissions.2005 ~year, emissions %>% subset(year<=2005  &year>1980))$coef[2]*100,1),
                      round(lm(value/emissions.2005 ~year, emissions %>% subset(year>=2005))$coef[2]*100,1))



p07<- ggplot(emissions %>% subset(year>1980), aes(year, value- emissions.2005, col=time, fill=time))+
  geom_smooth(  se=T,   size=.2, method="lm", alpha=.3) +
  #  geom_smooth( data= oil.con %>% subset(year>1980 & year<2005), se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
  # geom_smooth( data= oil.con %>% subset(year> 2004), se=T, colour="white", fill="darksalmon", size=.2, method="lm", alpha=.3) +
  geom_line(size=.3 ) +
  geom_point(colour="white", size=2 ) +
  geom_point(size=1.5)+
  theme(axis.text.y.right = element_text(color = my.cols[2]),
        
        axis.title.y.right= element_text(angle = -90, hjust = 1, color = my.cols[2]))+
  # annotate("text", x=1995, y=8, label= "oil consumption added\n ", size=6, col="red3")+
  annotate("text", x=2012, y=-20, label= paste("energy sector added\n~", signif(abs(emissions.2018 -emissions.2005 ) ,3) ,"million tonnes CO2-e\n in 2018  cf. 2005"), 
           fontface =3, size=4, col=my.cols[2])+
  # annotate("text", x=2011, y=-24, label= paste("assuming", mtoc2co2e," mill. tonnes CO2\nfor every mill. tonnes oil"), fontface=3, size=2.5, col="grey70")+
  
  #  scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
  geom_hline(yintercept = 0,  size=.25 ,linetype=2)+
  # annotate("text", x=2016.7, y=.4, label= "2005 level", size=3)+
  annotate("text", x=1989, y=-80, label= paste0(coal.growth.rate[1], "% p.a."), size=4, col=my.cols[1])+
  annotate("text", x=2012, y=45, label= paste0(coal.growth.rate[2], "% p.a."), size=4, col=my.cols[2])+
  scale_colour_manual(values=rev(my.cols))+
  scale_fill_manual(values=rev(my.cols))+
  geom_hline(yintercept = -emissions.2005*.26,  size=.25 ,linetype=2, colour=my.cols[2])+
  annotate("text", x=2012, y=-emissions.2005*.26+6, label= "26% below 2005 levels", size=3,colour=my.cols[2],fontface =3)+
  
  labs(y="CO2-e million tonnes, cf. 2005", x=NULL, 
       subtitle="A ministerial energy primer #7\nAustralian Energy sector emissions, BP Statistical Review 2018",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
  theme(legend.position="None")

return (list(p1=p01,p1a=p01a,  p1b=p01b, p1c= p01c , p2=p02,  p3=p03 , p3a=p03a , p4=p04 ,p5=p05, p5a=p05a, p6=p06, p7=p07))
}

