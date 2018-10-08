message("return plot with 'repro()'")
source('/Volumes/data/Dropbox/msandifo/documents/programming/r/twitter/2018/Repro_gladstone_01.R')
repro() %>% show()
ggsave("/Volumes/data/Dropbox/msandifo/documents/programming/r/twitter/2018/charts/twitter_01.png", width=8, height=5) 





gas.use <-data.table::fread("/Volumes/data/Dropbox/msandifo/documents/programming/r/twitter/2018/001/data/gas_generation.csv")
names(gas.use) <- stringr::str_to_lower(names(gas.use))
gas <- tidyr::gather(gas.use, key,value, -year, -month) %>% 
  dplyr::mutate(date = lubridate::ymd(paste0(year,"-",month,"-15")) ,
mdays = lubridate::days_in_month(date),
mw= value*1e3/(mdays*24)*12, gas.type= stringr::str_remove_all(key, "gas_"))

NEM.month<-readd(NEM.month)

ggplot(gas, aes(date, mw ))+geom_area(aes( fill=gas.type), col="white", size=.2,position = "stack")+
  geom_vline(xintercept = lubridate::ymd(c("2012-07-01", "2014-07-17")),
             col="red3", size=.2, linetype=2) +
  geom_vline(xintercept = lubridate::ymd(c("2017-04-01")), col="darkgreen", size=.2, linetype=2) +
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2012-07-15"), y=3300 ,
                                    label="start\nC-Tax"), hjust=-0.,col="Red3", size=3)+
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2014-07-28"), y=3300 , 
                                    label="end\nC-Tax"), hjust=-0.,col="Red3", size=3)+
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2017-04-19"), y=3300,
                                    label="Hazelwood\nclosure"), hjust=-0.,col="darkgreen", size=3)+
  theme(legend.position = "bottom")+
  labs(x=NULL, y="MW")+
  
ggsave("/Volumes/data/Dropbox/msandifo/documents/programming/r/twitter/2018/001/figs/gas_gen_01.png", width=8, height=5) 

merge(NEM.month, gas, by=c("year","month")) -> gas.merge
gas.merge$p="2016+" ; gas.merge$p[(gas.merge$year+gas.merge$month/12.65) <2016. ]="2016-"
ggplot(gas.merge, aes(  mw*12,RRP, col=factor(year), fill=p)) +geom_point()+geom_smooth(se=T, method="lm", alpha=.1)+ ylim(c(20,130))
