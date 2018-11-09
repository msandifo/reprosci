#-----
# 007 download
#-----
#library(magrittr)

if (downloads){
reproscir::update_data("cape.grim.co2")
reproscir::update_data("cape.grim.ch4")
reproscir::update_data("eia.us.ng.withdrawals")
reproscir::update_data("bh.rc.bytrajectory")
reproscir::update_data("eia.hh.monthly.price")
}