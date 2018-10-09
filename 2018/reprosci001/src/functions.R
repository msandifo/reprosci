# packages neded
# tidyverse, lubridate, rvest, rappdirs, data.table, fasttime, purrr, hrbrthemes

# --------------------
# check packages
#---------------------

`%ni%` = Negate(`%in%`) 
cran.depend <- c("tidyverse", "lubridate", "rvest", "rappdirs","data.table", "fasttime", "magrittr", "devtools", "wbstats", "ggplot2" )
plic <- installed.packages()
cran.installs <-cran.depend[cran.depend  %ni% plic]
if (length(cran.installs >0)) install.packages(cran.installs)
if  ("hrbrthemes" %ni% plic) devtools::install_github("hrbrmstr/hrbrthemes")

# --------------------
# general functions
#---------------------

# copied directly from smapr
#' @importFrom rappdirs user_cache_dir
#' 
validate_directory <- function(destination_directory, folder="aemo") {
  if (is.null(destination_directory)) {
    destination_directory <- rappdirs::user_cache_dir(folder)
  }
  if (!dir.exists(destination_directory)) {
    dir.create(destination_directory, recursive = TRUE)
  }
  destination_directory
}

# --------------------
# functions for downloading and tidying NEM data for years 2010 -2018
#---------------------
download_aemo_current <- function(states = c("NSW", "QLD", "SA", "TAS", "VIC"),
                                  remote.path="http://www.nemweb.com.au/mms.GRAPHS/DATA/",
                                  local.path= NULL
) {
  local.path=validate_directory(local.path)
   for (state in states) {
    file.name <- paste0("DATACURRENTMONTH_", state, "1.csv")
    remote.url <- paste0(remote.path, file.name)
    local.file <- paste0(local.path, file.name)
    download.file(remote.url, local.file)
  }
}

#require(lubridate)
download_aemo_aggregated <- function(states = c("NSW","QLD","SA", "TAS", "VIC"),
                                     remote.path="http://www.nemweb.com.au/mms.GRAPHS/data/",
                                     local.path=NULL,
                                     months=NA,
                                     verbose=F,
                                     years=NA) {
  
  local.path=validate_directory(local.path)
  if (is.na(months[1])) months <- lubridate::month(Sys.Date())-1 #defaults to last month
  if (is.na(years[1])) years <- lubridate::year(Sys.Date())  # defaults to this year
  if (months[1]==0) {months[1]<-12; years[1]<- years[1]-1}
    for (this.year in years){
      for (this.month in months){
        for (this.state in states){
           
          month.name <-format(ISOdate(this.year,this.month,1),"%B") #previous month
        if (verbose)  message(paste(month.name, this.year, this.state))
        
        # make  this.month string 2 chatacter's long by adding "0"
        if (this.month < 10) file.name<- paste0("DATA", this.year,"0", this.month,"_", this.state,"1.csv") else
          file.name <- paste0("DATA", this.year, this.month,"_", this.state,"1.csv")
        
        remote.url <- paste0(remote.path, file.name)
        
        
        local.file <-paste0(local.path,"/", file.name)
        if (verbose)   message(local.file)
       if ((this.year< lubridate::year(Sys.Date()) | this.month< (lubridate::month(Sys.Date())) )){ 
         if (!file.exists(local.file))   download.file(remote.url, local.file) else
          message(remote.url," already downloaded")}
      }
    }
  }
}

#note spetember 2016 csv dates are ordered d.m.y as opposed to y.m.d in all others
# rather opaque attempoted to reorder dates - could be radically simplified

reorder_dmy <-function(my.dates){
  my.locs<-stringr::str_locate(my.dates, c("/" ))
  inds<-which(my.locs[,1]<4)
  #print(inds)
  my.splits<-stringr::str_split(my.dates[inds]," ")
  my.u.d<-sapply(my.splits, "[[", 1)
  my.u.d.2<-sapply(my.splits, "[[", 2)
  my.u.d.1 <-stringr::str_split(my.u.d, "/") %>% 
    sapply("rev") %>% 
    t() %>% 
    as.data.frame() %>%
    apply(  1, paste, collapse="/")%>% 
    as.data.frame() %>%
    dplyr::mutate(V4=paste0(" ", my.u.d.2))  %>%
    apply(  1, paste0, collapse="")
   my.dates[inds]<-my.u.d.1  
    my.dates[stringr::str_length(my.dates)==16] <-  stringr::str_c(my.dates[stringr::str_length(my.dates)==16], ":00")
  my.dates
}   
 
 # get_files uses fasttime, data.table packages
 
get_aemo_data<- function(local.path=NULL, state="NSW") {
   local.path=validate_directory(local.path)
  list.files(local.path) -> my.files
  my.files<-paste0(local.path, "/",my.files[stringr::str_detect(my.files,state) | stringr::str_detect(my.files,"201609")] )
    dt<-data.table::rbindlist(lapply( my.files, data.table::fread, colClasses= c("character", "character", "numeric","numeric","character"), drop="PERIODTYPE"))
  dt$SETTLEMENTDATE<- reorder_dmy(dt$SETTLEMENTDATE) %>% fasttime::fastPOSIXct(  tz="GMT",required.components=3)
  dt$month <- lubridate::month(dt$SETTLEMENTDATE)
  dt$year<- lubridate::year(dt$SETTLEMENTDATE)
 dt %>% subset(year<=lubridate::year(Sys.Date()) & year >= 2010 ) #nb. checks for errors with POSIXCt translation
 }
 
 # --------------------
 # functions for gladstone lng data
 #---------------------
 library(rvest)

# reads an individual gladstone port authority html table - montly
read_gladstone_ports<- function(year=NULL, 
                                month=NULL,
                                fuel="Liquefied Natural Gas",
                                country="Total"){
  args <- as.list(match.call()) # print(exists("args$year"))
  if (is.null(year)) year <- lubridate::year(Sys.Date())
  if (is.null(month)) {
    current.month <- lubridate::month(Sys.Date())
    #current month not posted (usually not posted until second week of current month)
    
    if (current.month>1 ) month <- current.month- 1  else  {
      month=12
      year<-year-1
    }
  }
  if (month>= 10) yearmonth= paste(year,month, sep="") else 
    yearmonth= paste(year,month, sep="0")
  message(paste(fuel,  month.abb[month], year))
  url<-paste0("http://content1.gpcl.com.au/viewcontent/CargoComparisonsSelection/CargoOriginDestination.aspx?View=C&Durat=M&Key=",yearmonth)
  wg <- rvest::html_session(url )
  batches <- read_html(wg) %>%
    rvest::html_nodes("#MainContent_pnlResults")   #class(batches)
  table <- batches %>%
    rvest::html_nodes("td") %>%
    rvest::html_text()
  lng.ind <- which( table==fuel)
  t.ind <-which(stringr::str_detect(table,country))
  t.lng.ind  <- t.ind[t.ind>lng.ind][1]
  value <- table[t.lng.ind+1] %>% stringr::str_replace_all(",","") %>%as.numeric()
  mdays <- lubridate::days_in_month(lubridate::ymd(paste(year,month, "01", sep="-")))
  if(country=="Total"){
    ships <- table[t.lng.ind+2] %>% stringr::str_replace_all(",","") %>%as.numeric()
    return(data.frame(year=year, 
                      month=month, 
                      date=lubridate::ymd(paste(year,month, "15", sep="-")),
                      tonnes=value, 
                      shipments=ships, 
                      mdays=mdays))
  } else 
    return(data.frame(year=year, 
                      month=month,  
                      date=lubridate::ymd(paste(year,month, "15", sep="-")),
                      tonnes=value,
                      mdays=mdays))
}

 # requires purrr
 #reads a sequence of gladstone port authority tables
 read_gladstone_year <- function(years=2015:lubridate::year(Sys.Date()),fuel="Liquefied Natural Gas", country="Total"){
   y= rep(years, each=12)
   m= rep(1:12,  length(years))   #l  <- list(y=2016:2017,m=1:2 )
   my_fun <- function(y,m, fuel="Liquefied Natural Gas", country="Total") read_gladstone_ports(year=y, month=m, fuel=fuel,country = country )
   purrr::map2_df(y,m, my_fun,  fuel=fuel, country=country)
 }
 
 
 update_gladstone <- function(local.path=NULL, years=2015:lubridate::year(Sys.Date())){
   local.path=validate_directory(local.path, folder="gladstone")
   gladstone.file = paste0(local.path, "/", "lng.Rdata")
   if (!file.exists(gladstone.file)) {
     read_gladstone_year(years=years ) -> lng
    save(lng, file=gladstone.file )} else load(gladstone.file)
   lng
 }
 
 # --------------------
 # script for dowloading and tidying NEM data for years 2010 -2018
 #---------------------

# update_gladstone()->lng
# download_aemo_aggregated(year=2010:2018, months=1:12)
# download_aemo_current()
 
# NSW1 <-get_aemo_data(state="NSW")# %>% padr::pad()
# VIC1 <-get_aemo_data(state="VIC")
# SA1 <- get_aemo_data(state="SA")
# QLD1  <-get_aemo_data(state="QLD")
# TAS1  <-get_aemo_data(state="TAS")
#  
# aemo <- data.table::rbindlist(list(NSW1,QLD1,SA1,TAS1,VIC1)) 
# 
# # nb 5 regionns being summed so lenegth is 5x number of time increments
# 
# NEM.month <- aemo %>% 
#   dplyr::group_by(year, month) %>% 
#   dplyr::summarise(date=mean(SETTLEMENTDATE)%>% as.Date(),
#                    RRP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
#                    TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND) )  
# 
# 
# NEM.year <- aemo %>% 
#   dplyr::group_by(year) %>% 
#   dplyr::summarise(date=mean(SETTLEMENTDATE) %>% as.Date(),
#                    RRP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
#                    TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND))
# nb 5 regionns being summed so lenegth is 5x number of time increments



# --------------------
# ggplot themes
#---------------------
reprosci001<- function(lng=lng, NEM.month=NEM.month, NEM.year=NEM.year) {
  library(ggplot2)
  (NEM.year %>% subset(year %in% c(2015,2017)))$RRP %>% diff() -> nem.diff.15.17.RRP
  (NEM.year %>% subset(year %in% c(2017)))$TOTALDEMAND -> nem.17.TD
  nem.diff.bill.dollars <-nem.diff.15.17.RRP*nem.17.TD*24*365/1e9
  
  # population data form world bank useing wbstats package
  pop<- wbstats::wb(country = c("AUS"), indicator = "SP.POP.TOTL", startdate = 2017, enddate = 2017)$value
  nem.diff.dollars.person<- nem.diff.bill.dollars/pop*1e9
  


# --------------------
# graphics routines
# --------------------
#ggplot(NEM.month, aes(date, RRP))+geom_line()

 
 
ggplot(lng  , aes(date, tonnes/1e6/mdays*365))+ geom_line(data=NEM.month , aes(y=RRP/5 ), size=.3, col="red2" )+
  geom_smooth(data=NEM.month , aes(y=RRP/5), size=0, span=.25,  fill="red3",alpha=.1)+ 
  scale_y_continuous(sec.axis = sec_axis(~.*5, "NEM - $/MW hour") )+
  coord_cartesian(ylim=c(0,25))+
  theme(axis.text.y.right = element_text(color = "red3"),
        axis.title.y.right= element_text(angle = -90, hjust = 0, color = "red3"),
        legend.position="None")+
  #scale_size_manual(values=c(.3,.3,.4,.3))+
  geom_vline(xintercept = lubridate::ymd(c("2012-07-01", "2014-07-17")),
             col="red3", size=.2, linetype=2) +
  geom_vline(xintercept = lubridate::ymd(c("2017-04-01")), col="darkgreen", size=.2, linetype=2) +
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2012-07-15"), y=25,
                                    label="start\nC-Tax"), hjust=-0.,col="Red3", size=3)+
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2014-07-28"), y=25, 
                                    label="end\nC-Tax"), hjust=-0.,col="Red3", size=3)+
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2017-04-19"), y=25,
                                    label="Hazelwood\nclosure"), hjust=-0.,col="darkgreen", size=3)+
  geom_label(data = data.frame(),aes(x=lubridate::ymd("2017-06-30"), y=5,
                                     label=paste0("2017 cf 2015\n+$",
                                                  round(nem.diff.15.17.RRP*nem.17.TD*24*365/1e9, 1),
                                                  " billion\n~ $", signif(nem.diff.dollars.person,2), 
                                                  " per cap.")), 
             col="Red3", size=4)+
  geom_smooth(data=NEM.month %>%subset(year == 2015 | year==2017) ,
              aes(y=RRP/5, group=year), method="lm", formula=y~1, size=2.,  colour="white",  se=F)+
  geom_smooth(data=NEM.month %>%subset(year == 2015 | year==2017) ,
              aes(y=RRP/5, group=year), method="lm", formula=y~1, size=.7,  colour="red3",  se=F)+
  geom_smooth(size=0, span=.35)+
  geom_line(size=.15)+ 
  geom_point(size=1.25, colour="white")+
  geom_point(size=.75)+
  labs(subtitle="Gladstone LNG exports, NEM prices", x=NULL, 
       y="million tonnes - annualised", caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/reprosci001")+
  theme(plot.caption=element_text(colour="grey80", size=8,hjust=1) )

}

 reprosci002 <- function(gas.use,gas, NEM.month ){
  #gas.use <-data.table::fread("/Volumes/data/Dropbox/msandifo/documents/programming/r/twitter/2018/001/data/gas_generation.csv")

#NEM.month<-readd(NEM.month)

p1<-ggplot(gas, aes(date, mw/1000 ))+geom_area(aes( fill=gas.type), alpha=.85,col="white", size=.2,position = "stack")+
  geom_vline(xintercept = lubridate::ymd(c("2012-07-01", "2014-07-17")),
             col="red4", size=.2, linetype=2) +
  geom_vline(xintercept = lubridate::ymd(c("2017-04-01")), col="darkgreen", size=.2, linetype=2) +
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2012-07-15"), y=3.200 ,
                                    label="start\nC-Tax"), hjust=-0.,col="Red4", size=3)+
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2014-07-28"), y=3.200 , 
                                    label="end\nC-Tax"), hjust=-0.,col="Red4", size=3)+
  geom_text(data = data.frame(),aes(x=lubridate::ymd("2017-04-19"), y=3.200,
                                    label="Hazelwood\nclosure"), hjust=-0.,col="darkgreen", size=3)+
  theme(legend.position = "bottom")

p1 +geom_line(data=NEM.month %>% subset(date< max( gas$date)+months(1)), aes(y=RRP*20/1000))+
  coord_cartesian(ylim=c(0,3.200))+
  scale_y_continuous(sec.axis = sec_axis(~.*.05*1000, "NEM - $/MW hour") )+
  theme(axis.text.y.left = element_text(color = "red3"),
        axis.title.y.left= element_text(  color = "red3"),
        axis.title.y.right= element_text(angle = -90, hjust = 0, color = "black"))+
  labs(subtitle="NEM gas generation, prices", x=NULL, 
       y="gigawatts", caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/reprosci001")+
  theme(plot.caption=element_text(colour="grey80", size=8,hjust=1) )}


reprosci003 <- function( gas.efficiency, gas){
 # names(gas.use) <- stringr::str_to_lower(names(gas.use))
  #30-35% for steam (i.e. Torrens & Northern), 45%-50% for CCGT, and 30-35% for OCGT. 
  

  # gas.effciency<- gas.use %>% dplyr::mutate(date = lubridate::ymd(paste0(year,"-",month,"-15")),
  #                                           sum = gas_ccgt+gas_ocgt+gas_steam,
  #                                           efficiencyLower =(gas_ccgt*.45 +gas_ocgt*.3 + gas_steam*.3 )/sum,
  #                                           efficiencyUpper =(gas_ccgt*.5 + gas_ocgt*.35 + gas_steam*.35 )/sum)
  
  
  ggplot(gas, aes(date, mw/1000 ))+ geom_area(aes( fill=gas.type), alpha=.85,col="white", size=.2,position = "fill")+
    geom_vline(xintercept = lubridate::ymd(c("2012-07-01", "2014-07-17")),
               col="red4", size=.2, linetype=2) +
    geom_vline(xintercept = lubridate::ymd(c("2017-04-01")), col="darkgreen", size=.2, linetype=2) +
    geom_text(data = data.frame(),aes(x=lubridate::ymd("2012-07-15"), y=.900 ,
                                      label="start\nC-Tax"), hjust=-0.,col="Red4", size=3)+
    geom_text(data = data.frame(),aes(x=lubridate::ymd("2014-07-28"), y=.900 , 
                                      label="end\nC-Tax"), hjust=-0.,col="Red4", size=3)+
    geom_text(data = data.frame(),aes(x=lubridate::ymd("2017-04-19"), y=.900,
                                      label="Hazelwood\nclosure"), hjust=-0.,col="darkgreen", size=3)+
    theme(legend.position = "bottom")+
    geom_line(data=gas.efficiency, aes(y=efficiencyLower), size=.2)+
    geom_line(data=gas.efficiency, aes(y=efficiencyUpper), size=.2)+
    coord_cartesian(ylim=c(0,.6))+
    scale_y_continuous(labels = scales::percent, breaks = seq(0,1,by=0.1))+
    labs(subtitle="NEM gas generation, thermal efficiency", x=NULL, 
         y=NULL, caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/reprosci001")
  
  
}
#--------
#drake plan
#------
# reproplan001 = drake::drake_plan(
#    lng = update_gladstone( local.path=local.path),
#    NSW1 = get_aemo_data(state='NSW'),# %>% padr::pad()
#    VIC1 = get_aemo_data(state='VIC'),
#    SA1  = get_aemo_data(state='SA'),
#    QLD1  =get_aemo_data(state='QLD'),
#    TAS1  =get_aemo_data(state='TAS'),
#    aemo = data.table::rbindlist(list(NSW1,QLD1,SA1,TAS1,VIC1)) ,
#    gas.use= gas.use <-data.table::fread(paste0(drake.path, "/data/gas_generation.csv"))%>%
#      purrr::set_names(~ stringr::str_to_lower(.)) %>% 
#      dplyr::mutate(date = lubridate::ymd(paste0(year,"-",month,"-15")),
#                    sum = gas_ccgt+gas_ocgt+gas_steam,
#                    efficiencyLower =(gas_ccgt*.45 +gas_ocgt*.3 + gas_steam*.3 )/sum,
#                    efficiencyUpper =(gas_ccgt*.5 + gas_ocgt*.35 + gas_steam*.35 )/sum),
#    gas.tidy = tidyr::gather(gas.use[,1:5], gas.type,value, -year, -month) %>% 
#      dplyr::mutate(date = lubridate::ymd(paste0(year,"-",month,"-15")) ,
#                    mdays = lubridate::days_in_month(date),
#                    mw= value*1e3/(mdays*24)*12, 
#                    gas.type=stringr::str_remove_all(gas.type, "gas_")),
#    
#    # nb 5 regions being summed so lenegth is 5x number of time increments
#    
#    NEM.month = aemo %>% 
#      dplyr::group_by(year, month) %>% 
#      dplyr::summarise(date=mean(SETTLEMENTDATE)%>% as.Date(),
#                       RRP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
#                       TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND) )  ,
#    
#    
#    NEM.year = aemo %>% 
#      dplyr::group_by(year) %>% 
#      dplyr::summarise(date=mean(SETTLEMENTDATE) %>% as.Date(),
#                       RRP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
#                       TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND)),
#    reprosci001.plot= reprosci001(lng, NEM.month, NEM.year),
#    reprosci002.plot= reprosci002(gas.use,gas.tidy, NEM.month ),
#    reprosci003.plot= reprosci003( gas.use,gas.tidy  )
#    
#    
#  )








