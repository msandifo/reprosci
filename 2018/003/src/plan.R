#--------
#drake plan
#------

reproplan = drake::drake_plan(
  load(file_in("./data/data.Rdata")),
  p003 = plots(drake::readd(NEM.month), drake::readd(gasbb.prod.zone.month) )
)
