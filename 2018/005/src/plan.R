#--------
#drake plan
#------
pkgconfig::set_config('drake::strings_in_dots' = 'literals')
reproplan = drake::drake_plan(
  #add data munging here
  
  countries=c("Norway", "Australia"  ),
  
  measures =c("GGXCNL",  "GGXONLB","NGDPDPC","NGDPPC","LP" ) ,
  #measures =c("GGR", "GGX","GGXCNL","NGDPDPC","NGDPPC","LP" ),
  
  imf.data=purrr::map2_df (rep(countries,each=length(measures)), 
                            rep(measures,length(countries)), 
                            reproscir::read_IMF  )   %>%
    dplyr::mutate(year=as.numeric(year))%>%
    tidyr::spread( measure, value  ) %>% 
    dplyr::arrange(region, year) %>%
    subset(year>1989 & year<= 2020) %>%
    dplyr::group_by(region ) %>%
    # dplyr::mutate(GGR.cum=cumsum(GGR), GGX.cum=cumsum(GGX),GGXCNL.cum=cumsum(GGXCNL))
    dplyr::mutate( US.exchange=NGDPDPC/NGDPPC,GGXCNL.cum=cumsum(GGXCNL), GGXONLB.cum=cumsum(GGXONLB)) %>%
    dplyr::select(year, region,LP,US.exchange,GGXCNL, GGXCNL.cum, GGXONLB, GGXONLB.cum),
  
   print(tail( imf.data)),
  ##------------
  
  ff.prod.sheets =rbind(reproscir::BP_sheets(search=c(    "oil", "prod", "tonne"), and=T),
                        reproscir::BP_sheets(search=c(     "prod", "mtoe"), and=T)) ,
  ff.cons.sheets =rbind(reproscir::BP_sheets(search=c(    "oil", "con", "tonne"), and=T),
                        reproscir::BP_sheets(search=c(     "con", "mtoe"), and=T)) [2:4,],
  
  bp.prod.data= purrr::map_df (ff.prod.sheets$sheet, function(x) reproscir::BP_all(countries=countries, sheet=x, data=T)) %>%
    dplyr::group_by(year, region) %>% 
    dplyr::summarise(ff.prod.mtoe=sum(value)) , 
  
  bp.cons.data= purrr::map_df (ff.cons.sheets$sheet, function(x) reproscir::BP_all(countries=countries, sheet=x, data=T)) %>%
    dplyr::group_by(year, region) %>% 
    dplyr::summarise(ff.cons.mtoe=sum(value)),
  
  
  merged.data = dplyr::inner_join(imf.data, bp.cons.data ) %>% dplyr::inner_join(bp.prod.data),
  #merged.data =merge(x,y)
  p005= plots( merged.data ,   imf.data)

)
