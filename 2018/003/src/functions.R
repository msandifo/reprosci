
get_NEM_month <- function(){ 
  reproscir::read_aemo_aggregated() %>%  #read aemo data
  dplyr::group_by(year, month) %>% #add grouping vars
  dplyr::summarise(date=mean(SETTLEMENTDATE) %>% as.Date(),
                   RRP = sum(RRP*TOTALDEMAND)/sum(TOTALDEMAND), 
                   TOTALDEMAND=5*sum(TOTALDEMAND)/length(TOTALDEMAND) )    # add summaries
}

get_gladstone <- function() {
  reproscir::update_gladstone( )  %>%  
  dplyr::mutate(gasdate = date %>% reproscir::set_month_day(15),  # 
                actualquantity = reproscir::lng_tm_to_tjd(tonnes, date)) #convert monthly lng export tonnage to TJ/day equivalent
}

get_gasbb_zone_month <- function(gladstone, zones = c("Roma", "Moomba", "Gippsland", "Port Campbell", "Ballera", "Victoria", "Sydney") #  gasbb_zones_delivery zones selection -see next
){
reproscir::download_gasbb() %>%  
  reproscir::read_gasbb( ) %>% # group by zones
  subset(actualquantity<1e4) %>% #remove some spurious records in gasbb raw data
  subset(plantid %in%  reproscir::gasbb_ids("PROD")) %>%   #subset by production facilities using "./data/facility.Rdata"
  reproscir::gasbb_zones_delivery(zones =zones)   %>%  # read gasbb data
  dplyr::group_by(zonename, month, year) %>%  #set grouping variables
  dplyr::summarise(actualquantity=mean(actualquantity), 
                   gasdate=mean(gasdate) %>% reproscir::set_month_day(15)) %>%  #summarise by grouping variables
  dplyr::arrange(gasdate,zonename)   %>%  #arrange
  dplyr::left_join(  gladstone, by=c("gasdate", "month", "year"), suffix= c("", ".gld")) %>%  # join with gld 
  dplyr::arrange(gasdate) %>% #sort by date
  dplyr::mutate(gladstone= dplyr::if_else(is.na(actualquantity.gld)| zonename !="Roma", 0 ,  actualquantity.gld))%>%   #mutate gladstone
  dplyr::select(zonename,month,  year ,actualquantity ,gasdate , gladstone ) %>% #keep wanted info
  dplyr::rename(date=gasdate) 
}