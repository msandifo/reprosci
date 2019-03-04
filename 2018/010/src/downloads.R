#-----
# 010 download
#-----
#library(magrittr)

download_aemo_CO2EII()
update_aemo_CO2EII()

BP.file<-reproscir::BP2018_download( local.path=NULL,
                                     folder="BP",
                                     remote.url = "https://www.bp.com/content/dam/bp/business-sites/en/global/corporate/xlsx/energy-economics/statistical-review/bp-stats-review-2018-all-data.xlsx")#"https://www.bp.com/content/dam/bp/en/corporate/excel/energy-economics/statistical-review/bp-stats-review-2018-all-data.xlsx")  #dowload aemo data