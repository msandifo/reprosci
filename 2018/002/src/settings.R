if (!exists("full.repro")) full.repro=F
library(drake)
pkgconfig::set_config("drake::strings_in_dots" = "literals")
local.path=NULL
if (!exists("drake.path")) drake.path <- dirname(rstudioapi::getSourceEditorContext()$path )
setwd(drake.path)
