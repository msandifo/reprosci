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
  dplyr::summarise(te=mean(te), date=mean(date), co=mean(co))

nem.year = nem %>%
  dplyr::group_by(year ) %>%
  dplyr::summarise(te=mean(te), date=mean(date), co=mean(co))

nem.year.te.2005 = nem.year$te[nem.year$year=="2005"]

ggplot(nem.month, aes(date, co*te*365/1e6))+
  geom_line(aes(y=te*365/1e6), col="grey60")+ 
  geom_line( )+
  
  labs(y="NEM emissions, nnualised  million toness CO2-e", x=NULL)


ggplot(nem.month, aes(date,co* te/nem.year.te.2005))+
  geom_line(aes(y=te/nem.year.te.2005), col="grey60")+ 
  geom_line( )+
  scale_y_continuous(labels=scales::percent)+
  labs(y="NEM emissions, normalised to 2005 levels", x=NULL)

  
