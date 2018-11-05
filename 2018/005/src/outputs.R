p005<-drake::readd(p005)
  ggsave('./figs/p005_01.png',  p005$p1 ,width=8, height=5) 
  ggsave('./figs/p005_02.png',  p005$p2 ,width=8, height=5) 
  ggsave('./figs/p005_03.png',  p005$p3 ,width=8, height=5) 
  ggsave('./figs/p005_04.png',  p005$p4 ,width=8, height=5) 
  ggsave('./figs/p005_05.png',  p005$p5 ,width=8, height=5) 
  ggsave('./figs/p005_06.png',  p005$p6 ,width=8, height=5) 
  ggsave('./figs/p005_07.png',  p005$p7 ,width=8, height=5) 
  
  merged.data<-drake::readd(merged.data)
  save(merged.data, file="data/data.Rdata")
  