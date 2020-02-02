#--------
#drake plan
#------

reproplan = drake:drake_plan(
 load(file_in("./data/data.Rdata")),
  
  p001 = plots(lng=lng, NEM.month=NEM.month, NEM.year=NEM.year, gas=gas.tidy, gas.use=gas.use)
  
  
  
)
