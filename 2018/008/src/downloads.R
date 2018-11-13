#-----
# 008 download
#-----
# library(magrittr)
# library(lubridate)

msandifo=TRUE
if (msandifo==TRUE){
  ms_yaml_setup( outname="./data/data008.yaml",
                 data.sets = c("eia.us.ng.withdrawals.annual",
                               "eia.us.ng.withdrawals.month",
                               "eia.us.cbm.withdrawals.annual" ,
                               "eia.us.cbm.withdrawals.month",
                               "eia.us.cbm.annual")
                 )
  # reproscir::merge_yaml_files( sub=c("eia" ), name="temp.yaml")
  # reproscir::list_data_sets()
  # data.sets = c("eia.us.ng.withdrawals.annual",
  #               "eia.us.ng.withdrawals.month",
  #               "eia.us.cbm.withdrawals.annual" ,
  #               "eia.us.cbm.withdrawals.month",
  #               "eia.us.cbm.annual"
  # )
  #Sys.setenv(R_DATAYAML= "~/Dropbox/msandifo/data/data1.yaml")
 # o.datayaml<-Sys.getenv("R_DATAYAML")
  # my.yaml<-yaml::yaml.load_file(Sys.getenv("R_DATAYAML"))
  # my.data.yaml <- purrr::map(data.sets, reproscir::get_yaml, my.yaml=my.yaml) 
  # yaml::write_yaml(my.data.yaml, "./data/data008.yaml")
}
Sys.setenv(R_DATAYAML= "./data/data008.yaml")
yaml.sets <-reproscir::list_data_sets()
yaml.sets 

reproscir::update_data("eia.us.ng.withdrawals.annual", csv=F)
reproscir::update_data("eia.us.ng.withdrawals.month", csv=T)
reproscir::update_data("eia.us.cbm.withdrawals.month" , csv=F)
reproscir::update_data("eia.us.cbm.withdrawals.annual" , csv=F)
reproscir::update_data("eia.us.cbm.annual"  )
# eia.us.cbm.mon<-reproscir::read_data("eia.us.cbm.withdrawals.month" )
# eia.us.cbm.ann<-reproscir::read_data("eia.us.cbm.withdrawals.annual" )
# eia.us.ng.mon<-reproscir::read_data("eia.us.ng.withdrawals.month" )

 

