#--------
#drake plan
#------

reproplan = drake::drake_plan(
  NEM.month=get_NEM_month(),
  gladstone=get_gladstone_month(),
  gasbb.prod.zone.month =get_gasbb_zone_month(gladstone),
  p003 = plots(NEM.month, gasbb.prod.zone.month )
)
