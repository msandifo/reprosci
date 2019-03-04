library(magrittr)
library(ggplot2)
load("./data/aemo.CO2EII.RDATA")
#CO2EII  %>% names()

nem = CO2EII %>%
  subset(REGIONID=="NEM") %>%
  dplyr::rename(te="TOTAL_EMISSIONS", date="SETTLEMENTDATE", co="CORRECTION") %>%
  dplyr::mutate(year=lubridate::year(date), month=lubridate::month(date))

nem.month = nem %>%
  dplyr::group_by(year, month) %>%
  dplyr::summarise(total=mean(te), date=mean(date), total.corrected=mean(co*te)) %>%
  tidyr::gather(n, te, -date, -year, -month)

nem.year = nem %>%
  dplyr::group_by(year ) %>%
  dplyr::summarise(total=mean(te), date=mean(date), total.corrected=mean(co*te)) %>%
  tidyr::gather(n, te, -date, -year)%>% 
  dplyr::mutate(time= dplyr::case_when(year < 2005 ~ "low", year >=2005~ "high"))

nem.year.te.2005 = nem.year$te[nem.year$year==2005 &nem.year$n=="total.corrected" ]
nem.year.te.2017 = nem.year$te[nem.year$year==2017 &nem.year$n=="total.corrected" ]
#(nem.year.te.2005-nem.year.te.2017)*365/1e6


ggplot(nem.year %>% subset(year>2000 & n=="total.corrected"), aes(year, (te- nem.year.te.2005)*365/1e6, col=time, fill=time))+
#  geom_smooth( data=nem.year %>% subset(year>2007 & n=="total.corrected"), se=T, method="lm", size=.2,   alpha=.1 ) +
 # geom_smooth( data=nem.year %>% subset(year<=2008 & n=="total.corrected"), se=T, method="lm", size=.2,   alpha=.1 ) +
  #  geom_smooth( data= oil.con %>% subset(year>1980 & year<2005), se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
  # geom_smooth( data= oil.con %>% subset(year> 2004), se=T, colour="white", fill="darksalmon", size=.2, method="lm", alpha=.3) +
  geom_line(size=.3 ) +
  geom_point(colour="white", size=2 ) +
  geom_point(size=1.5)  +
     # annotate("text", x=1995, y=8, label= "oil consumption added\n ", size=6, col="red3")+
  annotate("text", x=2016, y=-7, label= paste("electrical power system CO2-e\n emissions reduced by \n~", 
                                              signif((nem.year.te.2005 -nem.year.te.2017)*365/1e6,2) ,"million tonnes \n in 2017  cf. 2005*"), 
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
       subtitle="NEM electrical power generation, AEMO",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
  theme(legend.position="None")


my.cols =c( "grey40","firebrick4" )
my.sizes= c(.2,.3 )
ggplot(nem.month, aes(date, te*365/1e6, colour=n, size=n))+
  #geom_line(aes(y=te*365/1e6), col="grey60")+ 
  geom_line( )+
  
  labs(y="annualised  million toness CO2-e", x=NULL, 
       subtitle="NEM emissions, AEMO" )+
  scale_color_manual(values=my.cols)+
  scale_size_manual(values=my.sizes)+
  theme(legend.position=c(.85,.85))

 
reproscir::BP_sheets()

emissions = reproscir::BP_all(verbose=F, sheet=57, countries="Australia", years=1969:2017 , units="mt", data=T ) %>% 
  dplyr::mutate(time= dplyr::case_when(year < 2005 ~ "low", year >=2005~ "high"))
emissions.2005 <-emissions$value[emissions$year==2005]
emissions.2017 <-emissions$value[emissions$year==2017]
coal.growth.rate <- c(round(lm(value/emissions.2005 ~year, emissions %>% subset(year<=2005  &year>1980))$coef[2]*100,1),
                      round(lm(value/emissions.2005 ~year, emissions %>% subset(year>=2005))$coef[2]*100,1))


 
ggplot(emissions %>% subset(year>1980), aes(year, value- emissions.2005, col=time, fill=time))+
  geom_smooth(  se=T,   size=.2, method="lm", alpha=.3) +
  #  geom_smooth( data= oil.con %>% subset(year>1980 & year<2005), se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
  # geom_smooth( data= oil.con %>% subset(year> 2004), se=T, colour="white", fill="darksalmon", size=.2, method="lm", alpha=.3) +
  geom_line(size=.3 ) +
  geom_point(colour="white", size=2 ) +
  geom_point(size=1.5)+
    theme(axis.text.y.right = element_text(color = my.cols[2]),
        
        axis.title.y.right= element_text(angle = -90, hjust = 1, color = my.cols[2]))+
  # annotate("text", x=1995, y=8, label= "oil consumption added\n ", size=6, col="red3")+
  annotate("text", x=2012, y=-20, label= paste("energy sector added\n~", signif(abs(emissions.2017 -emissions.2005 ) ,3) ,"million tonnes CO2-e\n in 2017  cf. 2005"), 
           fontface =3, size=4, col=my.cols[2])+
 # annotate("text", x=2011, y=-24, label= paste("assuming", mtoc2co2e," mill. tonnes CO2\nfor every mill. tonnes oil"), fontface=3, size=2.5, col="grey70")+
  
  #  scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
  geom_hline(yintercept = 0,  size=.25 ,linetype=2)+
  geom_hline(yintercept = -emissions.2005*.26,  size=.25 ,linetype=2, colour="red")+
  annotate("text", x=2014, y=-emissions.2005*.26+3, label= "26% below 2005 levels", size=3)+
  annotate("text", x=1989, y=-80, label= paste0(coal.growth.rate[1], "% p.a."), size=4, col=my.cols[1])+
  annotate("text", x=2012, y=40, label= paste0(coal.growth.rate[2], "% p.a."), size=4, col=my.cols[2])+
  scale_colour_manual(values=rev(my.cols))+
  scale_fill_manual(values=rev(my.cols))+
  labs(y="CO2-e million tonnes, cf. 2005", x=NULL, 
       subtitle="Energy sector emissions, BP Statistical Review 2018",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
  theme(legend.position="None")



oil.con = reproscir::BP_all(verbose=F, sheet=10, countries="Australia", years=1969:2017 , units="bcm", data=T ) %>% 
  dplyr::mutate(time= dplyr::case_when(year < 2005 ~ "low", year >=2005~ "high"))
oil.con.2005 <-oil.con$value[oil.con$year==2005]
oil.growth.rate <- c(round(lm(value/oil.con.2005 ~year, oil.con %>% subset(year<=2005  &year>1980))$coef[2]*100,1),
                 round(lm(value/oil.con.2005 ~year, oil.con %>% subset(year>=2005))$coef[2]*100,1))

mto2co2e= 3.159
ggplot(oil.con %>% subset(year>1980), aes(year, value- oil.con.2005, col=time, fill=time))+
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
  annotate("text", x=2002, y=7, label= paste("oil consumption added\n~", signif((tail(oil.con$value,1)-oil.con.2005 )*mto2co2e,2) ,"million tonnes CO2-e\n in 2017  cf. 2005"), 
           fontface =3, size=4, col=my.cols[2])+
  annotate("text", x=2011, y=-11, label= "assuming 3.159 mill. tonnes CO2\nfor every mill. tonnes oil", fontface=3, size=2.5, col="grey70")+
  
  #  scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
  geom_hline(yintercept = 0,  size=.25 ,linetype=2)+
  # annotate("text", x=2016.7, y=.4, label= "2005 level", size=3)+
  annotate("text", x=1989, y=-4, label= paste0(oil.growth.rate[1], "% p.a."), size=4, col=my.cols[1])+
  annotate("text", x=2013, y=5, label= paste0(oil.growth.rate[2], "% p.a."), size=4, col=my.cols[2])+
  scale_colour_manual(values=rev(my.cols))+
  scale_fill_manual(values=rev(my.cols))+
  labs(y="oil consumption - million tonnes, cf. 2005", x=NULL, 
       subtitle="Australian oil consumption, BP Statistical Review 2018",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
  theme(legend.position="None")


gas.con.t = reproscir::BP_all(verbose=F, sheet=27, countries="Australia", years=1969:2017 , units="mtoe", data=T ) %>% 
  dplyr::mutate(time= dplyr::case_when(year < 2005 ~ "low", year >=2005~ "high"))
 gas.con.t.2005 <-gas.con.t$value[gas.con.t$year==2005]
growth.rate.t <- c(round(lm(value/gas.con.t.2005 ~year, gas.con.t %>% subset(year<=2005  &year>1980))$coef[2]*100,1),
                 round(lm(value/gas.con.t.2005 ~year, gas.con.t %>% subset(year>=2005))$coef[2]*100,1))

mtogas2co2e= 2.35
ggplot(gas.con.t %>% subset(year>1980), aes(year, value- gas.con.t.2005, col=time, fill=time))+
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
  annotate("text", x=2006, y=12, label= paste("gas consumption added\n~", signif((tail(gas.con.t$value,1)-gas.con.t.2005 )*mtogas2co2e,2) ,"million tonnes CO2-e\n in 2017  cf. 2005"), 
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
       subtitle="Australian gas consumption, BP Statistical Review 2018",
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
  theme(legend.position="None")


gas.con.t = reproscir::BP_all(verbose=F, sheet=27, countries="Australia", years=1969:2017 , units="mtoe", data=T )
gas.con.t.2005 <-gas.con.t$value[gas.con.t$year==2005]
growth.rate.t <- c(round(lm(value/gas.con.t.2005 ~year, gas.con.t %>% subset(year<=2005  &year>1980))$coef[2]*100,1),
                   round(lm(value/gas.con.t.2005 ~year, gas.con.t %>% subset(year>=2005))$coef[2]*100,1))



reproscir::BP_sheets(searc="gas")

gas.con = reproscir::BP_all(verbose=F, sheet=25, countries="Australia", years=1969:2017 , units="bcm", data=T )
gas.prod = reproscir::BP_all(verbose=F, sheet=22, countries="Australia", years=1969:2017 , units="bcm", data=T )
gas.con.2005 <-gas.con$value[gas.con$year==2005]
growth.rate <- c(round(lm(value/gas.con.2005 ~year, gas.con %>% subset(year<=2005  &year>1980))$coef[2]*100,1),
                 round(lm(value/gas.con.2005 ~year, gas.con %>% subset(year>=2005))$coef[2]*100,1))

 ggplot(gas.con %>% subset(year>1980), aes(year, value/gas.con.2005))+
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
 
 ggplot(gas.lng%>% subset(year>1980), aes(year, (value-gas.lng.2005 )*.735 ))+
   # geom_smooth( data= gas.con %>% subset(year>1980 & year<=2005), fullrange=F, se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
   # geom_smooth( data= gas.con %>% subset(year> 2004), se=T, colour="white", fill="grey50", size=.2, method="lm", alpha=.3) +
    geom_line(size=.3 ) +
   geom_line(data=gas.lng %>% subset(year>=2005), size=.7 , col="red3", aes(y=(value-gas.lng.2005 )*.735*.3 )) +
   geom_point(colour="white", size=2 ) +
   geom_point(size=1.5)+
  # scale_y_continuous(labels=scales::percent_format(accuracy = 1))+
   geom_hline(yintercept = 0,  size=.25 ,linetype=2)+
   annotate("text", x=1995, y=40, label= "post 2005, LNG processing emissions adds- estimated", size=4, col="red3")+
   annotate("text", x=1995, y=37, label= paste(signif((tail(gas.lng$value,1)-gas.lng.2005 )*.735*.3,2) ,"mill.tonnes CO2-e"), size=4, col="red3")+
   # annotate("text", x=1992, y=-3, label= paste0(growth.rate[1], "% p.a."), size=4)+
   # annotate("text", x=2013, y=7, label= paste0(growth.rate[2], "% p.a."), size=4)+
   labs(y="million tonnes LNG,cf. 2005 levels", x=NULL, 
        subtitle="Australian gas exports, BP Statistical review, 2018",
        caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")+
   xlim(c(1987,2017))
 
 