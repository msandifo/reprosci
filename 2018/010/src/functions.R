`%ni%` = Negate(`%in%`) 
my.tz = "Australia/Brisbane"
signif_scale <- function(x,suffix="%", sig=2, scale=100) paste0(signif(scale*x, sig), suffix)


download_aemo_CO2EII <- function(remote.url="http://www.nemweb.com.au/reports/current/cdeii/CO2EII_Summary_Results.csv",
                                 local.file = "~/data/regional/australia/energy/aemo/emissions/CO2EII_Summary_Results.csv") {
  download.file(remote.url, local.file )
}

csv_merge <- function(local.path = "~/data/regional/Australia/energy/aemo/emissions",
                      cols = c("I", "CO2E11", "PUBLISHING", "FLAG", "CONTRACTYEAR", "WEEKNO",
                               "SETTLEMENTDATE", "REGIONID", "TOTAL_SENT_OUT_ENERGY", "TOTAL_EMISSIONS", "CO2E_INTENSITY_INDEX"),
                      classes = c("NULL", "NULL", "NULL", "NULL", "NULL", "NULL",
                                  "character", "factor", "numeric", "numeric", "numeric"),
                      skip = 2,
                      header = F,
                      tail.clip = -1,
                      file.pattern = "CO2EII_SUMMARY_RESULTS",
                      verbose=F) {
  
  filenames = list.files(path = local.path, full.names = TRUE, pattern = file.pattern)
  if (verbose==TRUE) print(filenames)
  datalist = lapply(filenames, function(x) {
    read.csv(file = x, header = header, skip = skip, col.names = cols, colClasses = classes)
  })
  Reduce(function(x, y) {
    merge(x, y)
  }, datalist)
  
  datalist = do.call("rbind", datalist)
  
  #check  order of character
  #	print(which( datalist$SETTLEMENTDATE =="" ))
  #  	datalist <- datalist[ datalist$SETTLEMENTDATE !="",]
  #  	str_locate(datalist$SETTLEMENTDATE, "/")[,1] -> my.inds
  # 	#   print(datalist$SETTLEMENTDATE[which(my.inds<5) ])  
  #   	datalist$SETTLEMENTDATE <-	str_trunc(datalist$SETTLEMENTDATE, 10, ellipsis="")
  #  # 	print(datalist$SETTLEMENTDATE[which(my.inds<5)])
  #   	my.dates<- as.Date( datalist$SETTLEMENTDATE  )
  # #  	print(my.dates[which(my.inds<5)])
  #   	my.dates[which(my.inds<5) ]<-as.Date(datalist$SETTLEMENTDATE[which(my.inds<5) ] , format="%d/%m/%Y")
  # #  	print(my.dates[which(my.inds<5)])
  #   	datalist$SETTLEMENTDATE<-my.dates
  # 	   #    str_locate(co2$SETTLEMENTDATE, "/")
  
  if (is.na(tail.clip))
    return(datalist)
  else return(head(datalist, tail.clip))
}

update_aemo_CO2EII <- function(correction=2.5, verbose=FALSE, save=T) {
  data.results <- csv_merge(verbose=verbose)
  data.historical <- csv_merge(local.path = "~/data/regional/Australia/energy/aemo/emissions/",
                               cols = c("CONTRACTYEAR", "WEEKNO", "SETTLEMENTDATE", "REGIONID",
                                        "TOTAL_SENT_OUT_ENERGY", "TOTAL_EMISSIONS", "CO2E_INTENSITY_INDEX"),
                               classes = c("NULL", "NULL", "character", "factor", "numeric", "numeric", "numeric"),
                               file.pattern = "HISTORICAL_SNAPSHOT",
                               verbose=verbose)
  
  data.results$SETTLEMENTDATE<-reorder_dmy(data.results$SETTLEMENTDATE)
  # print(head(data.results$SETTLEMENTDATE))
  # print(tail(data.results$SETTLEMENTDATE))
  # 
  # print(head(data.historical$SETTLEMENTDATE))
  # print(tail(data.historical$SETTLEMENTDATE))
  
  #	data.historical$SETTLEMENTDATE <- as.Date(data.historical$SETTLEMENTDATE, format = "%d/%m/%Y", tz="GMT")
  data.historical$SETTLEMENTDATE <- lubridate::dmy(data.historical$SETTLEMENTDATE,   tz=my.tz)  #"GMT")
  data.results$SETTLEMENTDATE <-  lubridate::ymd_hms(data.results$SETTLEMENTDATE,   tz=my.tz)  #"GMT")
  
  
  print(str(data.results))
  print(str(data.historical))
  #print(tail(data.results))
  data<- subset(rbind(data.historical, data.results), REGIONID %in% c("NSW1", "SNOWY1", "TAS1", "VIC1", "SA1","QLD1", "NEM") )
  data$CORRECTION =1+correction/100
  #	data$CORRECTION[data$SETTLEMENTDATE >= as.Date("01/06/2014",format = "%d/%m/%Y",  tz="GMT")]= 1
  data$CORRECTION[data$SETTLEMENTDATE >   "2014-06-01" ]= 1
  if (save==TRUE) {save_aemo_CO2EII(data, save.directory= "data/")
    }
  else return(data)
}

save_aemo_CO2EII <- function(data, var.name="CO2EII", save.directory="~/data/regional/Australia/energy/aemo/R/", file.name = "aemo.CO2EII.RDATA") {
  
  assign(var.name, data)
  out.file<-paste0(save.directory,file.name)
  
  print(paste("saving data.frame as ", var.name))   # n.b. deparse(substitute(var)) gets name of var as string
  print(paste("saving data.frame to ", out.file))
  
  save(list=var.name, file=out.file, compress=TRUE)
  return(out.file)
}

