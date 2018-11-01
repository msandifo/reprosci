p004<-drake::readd(p004)
ggsave("./figs/p004_01.png",  p004$p1 ,width=8, height=5) 
 
merged.data<- drake::readd(merged.data)
save( merged.data,  file = paste0(drake.path,"/data/data.Rdata"))
  
 

