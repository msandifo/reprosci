
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
 file.names=NULL
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
        file.names <- c(file.names, file.name)
      }
    }
    }
  return( file.names)
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
 
get_aemo_data<- function(local.path=NULL, state="NSW", files=NULL) {
   local.path=validate_directory(local.path)
  list.files(local.path) -> my.files
 
  if (!is.null(files)) my.files<- my.files[stringr::str_detect(my.files, files)]
  
  my.files<-paste0(local.path, "/",my.files[stringr::str_detect(my.files,state) | stringr::str_detect(my.files,"201609")] )
  
    dt<-data.table::rbindlist(lapply( my.files, data.table::fread, colClasses= c("character", "character", "numeric","numeric","character"), drop="PERIODTYPE"))
  dt$SETTLEMENTDATE<- reorder_dmy(dt$SETTLEMENTDATE) %>% fasttime::fastPOSIXct(  tz="GMT",required.components=3)
  dt$month <- lubridate::month(dt$SETTLEMENTDATE)
  dt$year<- lubridate::year(dt$SETTLEMENTDATE)
 dt %>% subset(year<=lubridate::year(Sys.Date()) & year >= 2010 ) #nb. checks for errors with POSIXCt translation
}

build_aemo <- function(files=NULL){
  
  NSW1 = get_aemo_data(state='NSW', files=files ) # %>% padr::pad()
  VIC1 = get_aemo_data(state='VIC',files=files ) 
  SA1  = get_aemo_data(state='SA', files=files  )
  QLD1 = get_aemo_data(state='QLD',files=files  ) 
  TAS1 = get_aemo_data(state='TAS',files=files ) 
  data.table::rbindlist(list(NSW1,QLD1,SA1,TAS1,VIC1))  
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
 


