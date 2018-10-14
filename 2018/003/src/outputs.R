p003<-drake::readd(p003)
ggsave("./figs/p003_01.png",  p003$p1 ,width=8, height=5) 
ggsave("./figs/p003_02.png",  p003$p2 ,width=8, height=5) 

NEM.month <- drake::readd(NEM.month)
gasbb.prod.zone.month <- drake::readd(gasbb.prod.zone.month)
gladstone<- drake::readd(gladstone)
save( NEM.month , gasbb.prod.zone.month, gladstone,  file = paste0(drake.path,"/data/data.Rdata"))
  
 

