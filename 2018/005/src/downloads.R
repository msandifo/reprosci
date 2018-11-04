
BP.file<-reproscir::BP2018_download( local.path=NULL,
                                     folder="BP",remote.url = "https://www.bp.com/content/dam/bp/en/corporate/excel/energy-economics/statistical-review/bp-stats-review-2018-all-data.xlsx")  #dowload aemo data
IMF.file<-reproscir::IMF2018_download(local.path=NULL,
                                      folder="IMF",
                                      remote.url = "https://www.imf.org/external/pubs/ft/weo/2018/01/weodata/WEOApr2018all.xls")
