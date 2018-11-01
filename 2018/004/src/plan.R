#--------
#drake plan
#------
pkgconfig::set_config("drake::strings_in_dots" = "literals")
reproplan = drake::drake_plan(
  countries = c("Australia","US",
                "France","China","Indonesia",
                "Japan", "Norway",
                "South Korea", "Canada", 
                "United Kingdom", "India",
                "Germany"),
  pop.data = purrr::map_df(countries, reproscir::read_IMF, measure="LP", percent=F) ,
  gdp.data = purrr::map_df(countries, reproscir::read_IMF, measure="PPPGDP" , percent=F) ,
  co2.data = reproscir::BP_all(verbose=F, sheet=57, countries=countries, fuel="CO2 emissions", units="Tonnes"),
   merged.data =merge(pop.data, co2.data$data[,1:3], by=c("region","year")) %>% 
    merge(gdp.data, by=c("region","year")) %>% 
    dplyr::mutate(perCap = value.y/value.x, year = as.numeric(year)) %>%
    dplyr::rename(pop=value.x, co2=value.y, gdp=value),
  
  p004 = plots( merged.data )
  
)
