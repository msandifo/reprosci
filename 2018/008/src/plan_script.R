#i"monthly.million.cubic.feet"

# billion or million
library(magrittr)
library(lubridate)
yaml.sets <-reproscir::list_data_sets()
yaml.sets
eia.us.cbm.mon <-reproscir::read_data("eia.us.cbm.withdrawals.month",data=T ) %>%
  dplyr::rename(cbm=US) %>%
  dplyr::mutate( date=as.Date(date)) #shoul correctly adjust for days inmonth
tail(eia.us.cbm.mon,10)
eia.us.cbm.ann<-reproscir::read_data("eia.us.cbm.withdrawals.annual" ,data=T) %>%
  dplyr::rename(cbm=US, date=Date) %>%
  dplyr::mutate( date=as.Date(date)) 

eia.us.ng.mon<-reproscir::read_data("eia.us.ng.withdrawals.month", data=T )[,c(1,3)]%>% 
  dplyr::rename(us.gas=us) %>%
  dplyr::mutate(us.gas=us.gas, date=as.Date(date)) #shoul correctly adjust for days inmonth

eia.us.ng.ann<-reproscir::read_data("eia.us.ng.withdrawals.annual", data=T)

prb.monthly.data = read.csv(paste(getwd(),"data/powder.river.basin.cbm.csv" ,sep="/")) %>% 
  dplyr::select(c("Month.Year", "Total.Gas.Mcf", "Total.Water.Bbls")) %>% 
  dplyr::rename(date=Month.Year, prb.cbm=Total.Gas.Mcf  ) %>%
  dplyr::mutate(date=stringr::str_c("15-", date) %>%
                  as.Date("%d-%b-%y"), prb.cbm = prb.cbm/1e3*30 ,  # MCF/DAY -> MMCF/MONTH
                Cum.Water.Bbls = cumsum(as.numeric(Total.Water.Bbls)))

prb.monthly.data  %>% head()

 
us.cbm.data <-read_data("eia.us.cbm.annual", data=T) %>% dplyr::rename(date= Date)%>% dplyr::mutate(cbm= US*1e9/tj2cf/365, date=as.Date(date))  

roma.daily.data = reproscir::download_gasbb() %>%
  reproscir::read_gasbb( ) %>%  
  dplyr::group_by(gasdate,zonename) %>% 
  subset(zonename =="Roma (ROM)"  & flowdirection =="DELIVERY") %>%
  dplyr::summarise(actualquantity=sum(actualquantity,na.rm=T) ) %>% 
  dplyr::arrange(gasdate) 


roma.monthly.data=roma.daily.data %>% 
  dplyr::mutate(month=month(gasdate), year=year(gasdate) ) %>%
  dplyr::group_by(month,year) %>%
  dplyr::summarise(actualquantity=mean(actualquantity,na.rm=T), gasdate=mean(gasdate) ) %>% 
  dplyr::arrange(gasdate)
library(reproscir)
data.source= "http://wogcc.state.wy.us/coalbedchart.cfm"

ggplot(prb.monthly.data, aes(date, prb.cbm*1e3/tj2cf  ))+
  geom_line()+
  labs (x=NULL, y="gas production, TJ/day", 
        subtitle=paste0("total US (green dashed)\n","Powder River Basin, Wyoming", " (black)\nSan Juan Basin, New Mexico, Colarado, Utah (black dash)\nRoma, Queensland (red) "), 
        caption=paste(data.source,"http://www.gasbb.com.au/Reports/Actual%20Flow.aspx")
        )+
  geom_line(data=head(tail(roma.monthly.data, -1),-1),  
            aes(gasdate,actualquantity), colour="red2")+
  # # geom_line(data=us.cbm.data, aes(x=as.Date(Date), y=TJ.d), linetype=2)+
  # # geom_line(data=us.dry.data, aes(x=as.Date(date), y=value), colour="green3")+
  geom_line(data=us.cbm.data , aes(x=date, y=cbm), linetype=2, col="green4")+
  geom_line(data=us.cbm.data, aes(x=date, y=
                                    rowSums( cbind (New.Mexico,Colorado,Utah ), na.rm=TRUE)*1e6*1e3/tj2cf/365), linetype=2, col="black")+
   #geom_line(data=us.cbm.data, aes(x=date, y=Colorado*1e6*1e3/tj2cf/365), linetype=2, col="darkgreen")+
  geom_point(data=us.cbm.data , aes(x=date, y=
                                      rowSums( cbind (New.Mexico,Colorado,Utah ), na.rm=TRUE)*1e6*1e3/tj2cf/365),  size=3, col="white")+
  geom_point(data=us.cbm.data, aes(x=date, y=
                                     rowSums( cbind (New.Mexico,Colorado,Utah ), na.rm=TRUE)*1e6*1e3/tj2cf/365),  size=.75, col="black")+
  scale_x_date(limits=ymd(c("1989-01-01","2017-08-01"))) 


names(eia.us.ng.ann)
library(ggplot2)
  
us.merged.mon <-merge(eia.us.cbm.mon ,eia.us.ng.mon )
ggplot(us.merged.mon, aes(date, cbm))+
  geom_line()+
  geom_point(data=eia.us.cbm.ann , aes(y=cbm/12), col="white", size=4)+
  geom_point(data=eia.us.cbm.ann , aes(y=cbm/12), col="blue4",size=3)+
  geom_line(data=prb.monthly.data , aes(y=prb.cbm ))


eia.us.ng.ann.gather<- tidyr::gather(eia.us.ng.ann[, c(1,3,4,5,6,7,8)], nom, value, -date )

eia.us.ng.ann.gather$value[eia.us.ng.ann.gather$nom =="shale" &  is.na(eia.us.ng.ann.gather$value)]<-0

# ggplot(eia.us.ng.ann %>% subset(date >lubridate::ymd("1970-01-01")), aes(date, cbm/gross*100 ))+#geom_line()+
#   geom_line( aes(y=shale/gross*100), col="red")+
#   geom_line( aes(y=gas.wells/gross*100), col="green2")+
#   geom_line( aes(y=oil.wells/gross*100), col="green2")+
#   geom_line( aes(y=non.hydrocarbon/gross*100), col="green2")
ggplot(eia.us.ng.ann.gather %>% subset(date >lubridate::ymd("1970-01-01")), aes(date,value, fill=nom)) +
  geom_area(posit="fill", col="white", size=.2)+
  theme(legend.position = c(.18,.7))

ggplot(eia.us.ng.ann.gather %>% subset(date >lubridate::ymd("1970-01-01")), aes(date,value, fill=nom)) +
  geom_area(posit="stack", col="white", size=.2)+
  theme(legend.position = c(.3,.8))

ggplot(prb.dat, aes(Month.Year,Total.Water.Bbls/1e6/cm2bbl ))+
  geom_line()+
  labs (x="date", y="total water production, mill cubic metres month", subtitle=region, caption=data.source)



ggplot(prb.monthly.data, aes(date,Cum.Water.Bbls/1e6/cm2bbl ))+
  geom_line()+
  geom_hline(yintercept= c(syd.harbour/1e6,syd.harbour/1e6*2), linetype=2, size=.2)+
  annotate("text", x=ymd("1990-01-01"), y= syd.harbour/1e6*1.05, label="1 Sydney Harbour")+
  annotate("text", x=ymd("1990-01-01"), y= 2*syd.harbour/1e6*1.025, label="2 Sydney Harbours")+
  labs (x="date", y="cumulative water production, million cubic metres", subtitle="Powder River Basin", caption=data.source)


col1<- "red2"; col2<- "blue3"
ggplot(prb.monthly.data, aes(date  ))+
  geom_line(aes(y = prb.cbm /1e6*30, col="Monthly gas production")  )+ 
  geom_line(aes(y = Cum.Water.Bbls/1e6/cm2bbl*.03333, col= "Cumulative water production"))+
  scale_y_continuous(sec.axis = sec_axis(~.*30, name = "cumulative water production\nmillion cubic metres") )+
  scale_colour_manual(values = c(col2,col1))+
  labs(y = "gas production, bcf per month",x = NULL , subtitle="Powder River Basin", caption=data.source)+
  theme(legend.position = c(0.3, 0.9), legend.title=element_blank())+
  geom_hline(yintercept= c(syd.harbour/1e6,syd.harbour/1e6*2)*.03333, linetype=2, size=.2 , col=col2)+
  annotate("text", x=ymd("1993-01-01"), y= syd.harbour/1e6*1.08*.03333, label="1 Sydney Harbour", col=col2)+
  annotate("text", x=ymd("1993-01-01"), y= 2*syd.harbour/1e6*1.04*.03333, label="2 Sydney Harbours", col=col2)


[,c(1,3)]%>% 
  dplyr::rename(us.gas=us) %>%
  dplyr::mutate(us.gas=us.gas) #shoul correctly adjust for days inmonth


us.monthly.data =  reproscir::read_data("eia.us.ng.withdrawals", data=T)[,c(1,3)] %>% 
  dplyr::rename(us.gas=us) %>%
  dplyr::mutate(us.gas=us.gas) #shoul correctly adjust for days inmonth

reproscir::read_data("eia.us.ng.withdrawals.month")$file
reproscir::read_data("eia.us.ng.withdrawals.month")$type$units
us.monthly.data  %>% tail()
us.monthly.data  %>% head()
NG_PROD_SUM_DC_NUS_MMCF_A.xls
reproscir::read_data("eia.us.ng.withdrawals.annual", data=T)
 readxl::read_xls("/Volumes/data/Dropbox/msandifo/documents/programming/r/twitter/2018/008/data/NG_PROD_SUM_DC_NUS_MMCF_A.xls",skip=2, sheet=2 , col_types=c("date", rep("numeric",11)))  %>% dplyr::mutate(Date=as.Date(Date))
strip <- function(strings, strip="", tolower=T, space=".", term= "(") {
 strings %>%
    stringr::str_remove_all(strip) %>%
    stringr::str_trunc(  stringr::str_locate(.,   term) )%>%
    stringr::str_to_lower() %>%
    stringr::str_to_lower() %>%
    stringr::str_squish( ) %>%
    stringr::str_replace_all(" ", space) 
}  
names(nf )%>% strip(strip="U.S.")
names(my.data)<- stringr::str_split(my.data.yaml$type$record.names,",")[[1]] %>% stringr::str_to_lower(); my.data$date <- lubridate::ymd( stringr::str_c(my.data$year, "-06-01")) ; 
my.data <- my.data %>% subset(!is.na(gross))

# annual.mcf
us.annual.data =  us.monthly.data %>% 
  dplyr::mutate(year=lubridate::year(date)) %>%
  dplyr::group_by(year) %>%
  dplyr::summarise(us.gas= sum(us.gas), date= lubridate::ymd(paste0(year,"-06-30")[1]))
# in mcf/day -> mmcf
prb.monthly.data = read.csv(paste(getwd(),"data/powder.river.basin.cbm.csv" ,sep="/")) %>% 
  dplyr::select(c("Month.Year", "Total.Gas.Mcf", "Total.Water.Bbls")) %>% 
  dplyr::rename(date=Month.Year, prb.cbm=Total.Gas.Mcf  ) %>%
  dplyr::mutate(date=stringr::str_c("15-", date) %>%
                  as.Date("%d-%b-%y"), prb.cbm = prb.cbm*30 , 
                Cum.Water.Bbls = cumsum(as.numeric(Total.Water.Bbls)))

prb.monthly.data  %>% head()

reproscir::read_data("eia.us.cbm.annual")$type$units
#"annual.billion.cubic.feet"
reproscir::read_data("eia.us.cbm.annual")$file
us.cbm.annual.data =reproscir::read_data("eia.us.cbm.annual", data=T)[ , c(1,2)]   %>%
  dplyr::rename(us.cbm= US) %>% 
  dplyr::rename(date=Date)%>%
  dplyr::mutate( us.cbm = us.cbm , date =as.Date(date))
(us.cbm.annual.data  %>% tail())

merged.monthly.data = merge(prb.monthly.data,us.monthly.data , by ="date")  
merged.annual.data = merge(us.cbm.annual.data,us.annual.data , by ="date")  
#merged.monthly.data = dplyr::bind_rows(prb.data,us.data   )  
(merged.monthly.data %>% str())
tail(merged.monthly.data)
(merged.annual.data %>% str())

ggplot(merged.monthly.data, aes(date, prb.cbm ))+
  geom_line() +
  geom_line(data=merged.annual.data, aes(y=us.cbm*1e6) )+
  geom_point(data=merged.annual.data, aes(y=us.cbm*1e6) )
  

ggplot(merged.monthly.data, aes(date, prb.cbm/us.gas*100))+
  geom_line() +
  geom_line(data=merged.annual.data, aes(y=us.cbm/us.gas*1e3*100) )+
  geom_point(data=merged.annual.data, aes(y=us.cbm/us.gas*1e3*100) )


us.annual.data= us.data$data %>% 
  dplyr::mutate(year=year(date)) %>%
  dplyr::group_by(year) %>% 
  dplyr::summarise(us =sum(us)) ,


merged.annual.data= merge(us.cbm.data, us.annual.data, by="year"),

aus.data =  reproscir::download_gasbb() %>%
  reproscir::read_gasbb( ) %>% 
  subset(flowdirection=="DELIVERY") %>%  #exclude pipeline "RECEIPTS"
  reproscir::group_gasbb("Roma") %>% 
  dplyr::mutate(year= lubridate::year(gasdate), month= lubridate::month(gasdate)) %>%
  dplyr::group_by(year,month) %>%
  dplyr::summarise(date=mean(gasdate), TOTALDEMAND = mean(reproscir::tjd_to_mw(actualquantity))),

roma.daily.data = reproscir::download_gasbb() %>%
  reproscir::read_gasbb( ) %>%  
  dplyr::group_by(gasdate,zonename) %>% 
  subset(zonename =="Roma (ROM)"  & flowdirection =="DELIVERY") %>%
  dplyr::summarise(actualquantity=sum(actualquantity,na.rm=T) ) %>% 
  dplyr::arrange(gasdate), 


roma.monthly.data=roma.daily.data %>% 
  dplyr::mutate(month=month(gasdate), year=year(gasdate) ) %>%
  dplyr::group_by(month,year) %>%
  dplyr::summarise(actualquantity=mean(actualquantity,na.rm=T), gasdate=mean(gasdate) ) %>% 
  dplyr::arrange(gasdate),

print(head(merged.data)),
