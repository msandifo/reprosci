
library(drake)
pkgconfig::set_config("drake::strings_in_dots" = "literals")
local.path=NULL
drake.path <- dirname(rstudioapi::getSourceEditorContext()$path )
setwd(drake.path)
source('./src/packages.R')
source('./src/functions.R')
source('./src/theme.R')
source('./src/plots.R')
source('./src/plan.R')
source('./src/downloads.R')
#drake::clean(reprosci001.plot,reprosci002.plot,reprosci003.plot)
#drake::drake_gc(verb=T)
drake::make( reproplan, force=T)
source('./src/outputs.R')
  
  
