#--------
#drake plan
#------
pkgconfig::set_config('drake::strings_in_dots' = 'literals')
reproplan = drake::drake_plan(
  #add data munging here
  
  sheet = reproscir::BP_sheets(search =c("prim","consumption"))$sheet,
  mtoe2j = 4.1868e16,
  j2tw = 1/3.156e7/1e12,
  tw2h=1/63,
  
  
  merged.data= reproscir::BP_all(sheet=sheet, countries="World")$data  %>%
    dplyr::mutate(value = value*mtoe2j*j2tw*tw2h),
  
  
   #merged.data =merge(x,y)
  p006= plots( merged.data )

)
