full.repro=T

parasitic.load=12  #set parasitc load as percentage

source('./src/settings.R')
source('./src/theme.R')
source('./src/functions.R')
source('./src/downloads.R')
if (file.exists('./src/plots.R')) source('./src/plots.R')
if (file.exists('./src/tables.R')) source('./src/tables.R') 
if (file.exists('./src/reports.R')) source('./src/reports.R') 

source('./src/plan.R')
if (full.repro==TRUE) drake::clean()
drake::make( reproplan, force =T)
source('./src/outputs.R')
  
  
