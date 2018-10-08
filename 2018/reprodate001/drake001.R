
library(drake)
pkgconfig::set_config("drake::strings_in_dots" = "literals")
local.path=NULL
drake.path <-
  dirname(rstudioapi::getSourceEditorContext()$path )

setwd(drake.path)
setwd("./src")
source('themes001.R')
source('functions001.R')
setwd(drake.path)

download_aemo_aggregated(year=2010:2018, months=1:12, local.path=local.path)
download_aemo_current( local.path=local.path )

clean(repromake001)
make( repromake001, force=T)

setwd("./figs")
ggsave("reprodate001.png",  readd(reprodate001.plot) ,width=8, height=5) 
ggsave("reprodate002.png",  readd(reprodate002.plot) ,width=8, height=5) 
ggsave("reprodate003.png",  readd(reprodate003.plot) ,width=8, height=5) 
setwd(drake.path)
  
  
