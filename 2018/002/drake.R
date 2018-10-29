if (!exists("full.repro")) full.repro=F
source('./src/settings.R')
source('./src/theme.R')
source('./src/functions.R')
source('./src/plan.R')
source('./src/plots.R')
source('./src/downloads.R')
if (file.exists('./src/plots.R')) source('./src/plots.R')
if (file.exists('./src/tables.R')) source('./src/tables.R') 
if (file.exists('./src/reports.R')) source('./src/reports.R') 
drake::clean(force=T)
drake::make( reproplan )
source('./src/outputs.R')
  
  
