
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

drake::clean(reprosci001.plot,reprosci002.plot,reprosci003.plot)
drake::drake_gc(verb=T)
drake::make( repromake001, force=T)

setwd("./figs")
ggsave("reprosci001.png",  readd(reprosci001.plot) ,width=8, height=5) 
ggsave("reprosci002.png",  readd(reprosci002.plot) ,width=8, height=5) 
ggsave("reprosci003.png",  readd(reprosci003.plot) ,width=8, height=5) 
setwd(drake.path)
  
  
