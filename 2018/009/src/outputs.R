p009<-drake::readd(p009)
  ggsave('./figs/p009_01.png',  p009$p1 ,width=8, height=5)
  merged.data<-drake::readd(merged.data)
  save(merged.data, file='data/data.Rdata')