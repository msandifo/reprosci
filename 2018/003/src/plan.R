#--------
#drake plan
#------

reproplan = drake::drake_plan(
  #load(file_in("./data/data.Rdata")),
  NEM.month=get_NEM_month(),
  gladstone=get_gladstone(),
  get.gasbb.zone.month=get_gasbb_zone_month(gladstone),
  p003 = plots(drake::readd(NEM.month), drake::readd(gasbb.prod.zone.month) )
)
