full.repro=T
source('./src/settings.R')
source('./src/theme.R')
source('./src/functions.R')
source('./src/plan.R')
source('./src/plots.R')

source('./src/downloads.R')
if (file.exists('./src/plots.R')) source('./src/plots.R')
if (file.exists('./src/tables.R')) source('./src/tables.R') 
#drake::clean(force=T)
#drake::drake_gc(verb=T)

if (full.repro==TRUE) drake::clean(force=T)

drake::make( reproplan )
source('./src/outputs.R')
  
  
