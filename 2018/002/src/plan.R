#--------
#drake plan
#------

reproplan = drake::drake_plan(
  load(file_in("./data/data.Rdata")),
  p002 = plots(drake::readd(QLD.month), drake::readd(lng), drake::readd(gasbb))
)
