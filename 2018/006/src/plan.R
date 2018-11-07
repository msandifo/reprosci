#--------
#drake plan
#------
pkgconfig::set_config('drake::strings_in_dots' = 'literals')
reproplan = drake::drake_plan(
  #add data munging here
  
  sheet = reproscir::BP_sheets(search =c("prim","consumption"))$sheet,
  merged.data= reproscir::BP_all(sheet=sheet, countries="World")$data  %>%
    dplyr::mutate(value = value*mtoe2j*j2tw*tw2h),
  
  
   #merged.data =merge(x,y)
  p006= plots( merged.data )

)
