#-----
# 003 download
#-----
#library(magrittr)
 

if (full.repro==TRUE) 
  file.names<-reproscir::download_aemo_aggregated(year=2008:2019, months=1:12, local.path=NULL)  #dowload aemo data

 