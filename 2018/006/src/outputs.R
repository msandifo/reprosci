p006<-drake::readd(p006)
  ggsave('./figs/p006_01.png',  p006$p1 ,width=8, height=5)

  merged.data<-drake::readd(merged.data)
  save(merged.data, file="data/data.Rdata")
