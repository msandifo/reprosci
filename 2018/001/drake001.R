
library(drake)
pkgconfig::set_config("drake::strings_in_dots" = "literals")

drake.path <-
  dirname(rstudioapi::getSourceEditorContext()$path )
setwd(drake.path)

setwd("./src")
source('themes001.R')
source('functions001.R')
setwd(drake.path)

download_aemo_aggregated(year=2010:2018, months=1:12)
download_aemo_current()


make(twitter001)
setwd("./figs")
ggsave("ms001.png",  readd(repo001.plot) ,width=8, height=5) 
ggsave("ms002.png",  readd(repo002.plot) ,width=8, height=5) 
setwd(drake.path)
  
  
