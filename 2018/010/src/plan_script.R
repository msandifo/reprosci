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
  tidyr::gather(n, te, -date, -year)

nem.year.te.2005 = nem.year$te[nem.year$year==2005 &nem.year$n=="total.corrected" ]
nem.year.te.2017 = nem.year$te[nem.year$year==2017 &nem.year$n=="total.corrected" ]
(nem.year.te.2005-nem.year.te.2017)*365/1e6
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
   annotate("text", x=1990, y=40, label= "post 2005, LNG processing emissions - estimated", size=4, col="red3")+
   annotate("text", x=1990, y=37, label= paste(signif((tail(gas.lng$value,1)-gas.lng.2005 )*.735*.3,2) ,"mill.tonnes CO2-e"), size=4, col="red3")+
   # annotate("text", x=1992, y=-3, label= paste0(growth.rate[1], "% p.a."), size=4)+
   # annotate("text", x=2013, y=7, label= paste0(growth.rate[2], "% p.a."), size=4)+
   labs(y="million tonnes LNG,cf. 2005 levels", x=NULL, 
        subtitle="Australian gas exports, BP Statistical review, 2018",
        caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/010")
 
 