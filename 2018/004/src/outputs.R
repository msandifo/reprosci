p004<-drake::readd(p004)
ggsave("./figs/p004_01.png",  p004$p1 ,width=8, height=5) 
ggsave("./figs/p004_02.png",  p004$p2 ,width=8, height=5) 
ggsave("./figs/p004_03.png",  p004$p3 ,width=8, height=5) 
# ggsave("./figs/p004_04.png",  p004$p4 ,width=8, height=5) 
# ggsave("./figs/p004_05.png",  p004$p5 ,width=8, height=5) 
# ggsave("./figs/p004_06.png",  p004$p6 ,width=8, height=5) 
merged.data<- drake::readd(merged.data)
save( merged.data,  file = paste0(drake.path,"/data/data.Rdata"))
  
 

