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
  #print(head(pop.data)),
  gdp.data = purrr::map_df(countries, reproscir::read_IMF, measure="PPPGDP" , percent=F) ,
  #      print(head(gdp.data)),
        co2.data = reproscir::BP_all(verbose=F, sheet=57, countries=countries, years=1969:2017,fuel="CO2 emissions", units="Tonnes" ),
 #       print(head(co2.data)),
        merged.data =merge(pop.data, co2.data$data, by=c("region","year")) %>% 
    merge(gdp.data, by=c("region","year")) %>% 
    dplyr::mutate(perCap = value.y/value.x, year = as.numeric(year)) %>%
    dplyr::rename(pop=value.x, co2=value.y, gdp=value),
  #      print(head(merged.data)),
  p004 = plots( merged.data )
  
)
