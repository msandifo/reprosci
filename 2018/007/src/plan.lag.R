#--------
#drake plan
#------
pkgconfig::set_config('drake::strings_in_dots' = 'literals')
reproplan = drake::drake_plan(
  #add data munging here
   
  
  cg.ch4= reproscir::read_data("cape.grim.ch4", data=T)  %>% 
    mutate(cdate=date, date=decimal_date(date)) %>%  
    
    subset(source != "Cape Grim air archive") %>%
    mutate(trend = (decompose(ts(value, frequency=12)))$trend %>% 
             as.numeric(  optional=T),
           lag = ( value - lag( value, 12)),
           lag.grad=  c(NA, (tail(lag, -1)/ head(value, -1))) ,
           trend.grad = 12* (c(NA, diff( trend)/tail( trend, -1))+
                               c( diff( trend)/head( trend, -1), NA))/2  ), # %T>% glimpse()
  # mutate( mutate( cdate = dmy(paste0("15-", month(date_decimal(date)),"-", year(date_decimal(date)) )))  -> 

  cg.ch4$trend.grad[is.na( cg.ch4$trend.grad)] =   cg.ch4$lag.grad[is.na( cg.ch4$trend.grad)], 
  
    us.gas = reproscir::read_data("eia.us.ng.withdrawals", data=T)[,c(1,3)] %>% 
       dplyr::mutate(cdate=as.Date(date), date=decimal_date(date), value=us) %>%  
    #   cdate = dmy(paste0("15-", month(date_decimal(date)),"-", year(date_decimal(date)) )) )  %>% 
    dplyr::select(date, cdate,value) %>%  
    subset(date > min(cg.ch4$date) & date<= max(cg.ch4$date) ) %>%
    dplyr::mutate(trend = (decompose(ts(value, frequency=12)))$trend %>% 
             as.numeric(  optional=T),
             lag = ( value - lag( value, 12)),
             lag.grad=  c(NA, (tail(lag, -1)/ head(value, -1))) ,
             trend.grad = 12* (c(NA, diff( trend)/tail( trend, -1))+
                                 c( diff( trend)/head( trend, -1), NA))/2 ) %>%
      rename(cdate=2,us=3) %>%
      dplyr::mutate(#cdate=as.Date(date,origin = "1970-01-01"), date=decimal_date(as.Date(date,origin = "1970-01-01")),
                    value=us) %>%  
      #   cdate = dmy(paste0("15-", month(date_decimal(date)),"-", year(date_decimal(date)) )) )  %>% 
      dplyr::select(date, cdate,value) %>%  
      subset(date > min(cg.ch4$date) & date<= max(cg.ch4$date) ) %T>%
    glimpse() %>%
    
      dplyr::mutate(trend = (decompose(ts(value, frequency=12)))$trend %>% 
                      as.numeric(  optional=T),
                    lag = ( value - lag( value, 12)),
                    lag.grad=  c(NA, (tail(lag, -1)/ head(value, -1))) ,
                    trend.grad = 12* (c(NA, diff( trend)/tail( trend, -1))+
                                        c( diff( trend)/head( trend, -1), NA))/2 ),
    
  us.gas$trend.grad[is.na( us.gas$trend.grad)] <-   us.gas$lag.grad[is.na(us.gas$trend.grad)], 
  
#  library(readxl)
  us.rig.count= reproscir::read_data("bh.rc.bytrajectory", data=T)  %>% 
    # mutate(date=decimal_date(date)) %>% 
    dplyr::select(1:4) %>% 
 tidyr::gather(  type, value,  -date)   %>% 
    mutate(cdate=date, date=decimal_date(date))  ,
  
  
  us.gas.info =reproscir::get_info("ei.us.ng.withdrawals"),
  cg.ch4.info= reproscir::get_info("cape.grim.ch4"),
  
  
  #-------
  # add deseasonlised trends  using decompose and trend grads
  #-------
  #centred =TRUE,  #use centred differencng for gradient determination (alternate is forward)
  
  # cg.ch4= cg.ch4 %>% dplyr::mutate(trend=decompose(ts(cg.ch4$value, frequency=12))$trend %>% 
  #   as.numeric(  optional=T)),
  # 
 
# glimpse(us.gas),
# 
# if (centred) cg.ch4$trend.grad = 12* (c(NA, diff(cg.ch4$trend)/tail(cg.ch4$trend, -1))+
#                                            c( diff(cg.ch4$trend)/head(cg.ch4$trend, -1), NA))/2 else
#                                              cg.ch4$trend.grad =  12* c(NA, diff(cg.ch4$trend)/tail(cg.ch4$trend, -1)) ,
#  # us.gas$trend  <- (decompose(ts(us.gas$value, frequency=12)))$trend %>% as.numeric(  optional=T) ,
#   
#   if (centred) us.gas$trend.grad = 12*( c(NA, diff(us.gas$trend)/tail(us.gas$trend, -1)) + 
#                                            c(diff(us.gas$trend)/head(us.gas$trend, -1), NA) )/2 else 
#                                              us.gas$trend.grad  =  12* c(NA, diff(us.gas$trend)/tail(us.gas$trend, -1)) ,
# 
  #-----
  # determine changepoints in cgrim data
#  library(changepoint)
  nq = 15 , # number of changepoints
  minseg = 12 , #nu,ber of months
  cg.ch4.narm = cg.ch4[ !is.na(cg.ch4$lag.grad),] ,#remove NA's
  my.cpt =  changepoint::cpt.mean( cg.ch4.narm$lag.grad , penalty="Manual",
                       pen.value=0.025,
                       method="BinSeg",
                       Q=nq,
                       test.stat="Normal",
                       class=TRUE,
                       param.estimates=TRUE,
                       minseglen=minseg),
  #--------
  # get us change point 1. Q-> 1
  #--------
  us.gas.narm = us.gas[ !is.na(us.gas$lag.grad),] ,#remove NA's
  us.gas.cpt =  changepoint::cpt.mean( us.gas.narm$lag.grad , penalty="Manual",
                           pen.value=0.025,
                           method="BinSeg",
                           Q=1,
                           test.stat="Normal",
                           class=TRUE,
                           param.estimates=TRUE,
                           minseglen=minseg),
  
  # sets our refernce time less one year
  us.gas.date = unique(us.gas.narm$cdate[us.gas.cpt@cpts.full]) ,
  my.date = us.gas.date , #-years(1) #ymd("2003-01-01")
  
  
  my.cpts.inds = sort(unique(as.numeric(my.cpt@cpts.full))) ,
  my.cpts  = tibble(cdate=cg.ch4.narm$cdate[my.cpts.inds] ) %>% 
    mutate(date =decimal_date(cdate),
           labels=format(cdate,  "%b %Y") ) , 
  my.cpt.dates = cg.ch4.narm$cdate[my.cpts.inds] ,
  
  my.cpt.ranges =  c(paste0( "< ", head(my.cpts$labels,1) ), 
                      paste0(head(my.cpts$labels,-1), " -\n", tail(my.cpts$labels,-1)),
                      paste0( "> ", tail(my.cpts$labels,1) )) ,
  
   annual.percentage.factor = 100, # annual percentage rise...
  
  cg.ch4.cpt.groupings = add_cpt_groups(cg.ch4, my.cpt.dates, col="cdate") %>% 
    group_by(group) %>% 
    dplyr::summarise(date=mean(date), 
              cdate=mean(cdate), 
              value=mean(value), 
              trend.grad=annual.percentage.factor*mean(lag.grad, na.rm=T) ) %>%
    dplyr::mutate(range= my.cpt.ranges ,  
           labels=paste0(round(trend.grad,2), "% p.a."),
           nlabels=paste0(round(trend.grad,2),"%" )) ,
  
  #write_csv(cg.ch4.cpt.groupings[, c(1,3,4,5)])
  
  
  us.cpt.groupings = add_cpt_groups(us.gas, my.cpt.dates, col="cdate") %>% 
    group_by(group) %>% 
    dplyr::summarise(date=mean(date), 
                     cdate=mean(cdate), 
                     value=mean(value), 
                     trend.grad=annual.percentage.factor*mean(lag.grad, na.rm=T) ) %>%
    mutate(range= my.cpt.ranges ,  
           labels=paste0(round(trend.grad,2), "% p.a."),
           nlabels=paste0(round(trend.grad,2),"%" )) %T>% glimpse() ,
  
  
  
  # my.cpt.data = merge(cg.ch4.cpt.groupings[, c(3,5, 6)], us.cpt.groupings[, c(5, 6)], by="range") %>% arrange(cdate) %>%
  #   mutate(grouping= cut(cdate,c(ymd("1900-1-01"), my.date ,ymd("2015-04-01"),ymd("2100-1-01")), labels=c("pre","post","last"))),
  
  my.cpt.data = merge(cg.ch4.cpt.groupings[, c(3,5, 6)], us.cpt.groupings[, c(5, 6)], by="range") %>%
    arrange(cdate) %>%
  mutate(grouping = cut(cdate,c(ymd("1900-1-01"), ymd("2000-01-01"), ymd("2100-1-01")), labels=c("pre","post"))) , 
  print(tail(  my.cpt.data)),
  cpt.models = my.cpt.data %>%
    split(.$grouping) %>%
    map(~lm(.$trend.grad.x ~ .$trend.grad.y, data=. )) ,
  
  cptfits =cpt.models %>% map(summary) %>%  map_dbl(~.$r.squared)  ,
  
print(cg.ch4),

cg.us=cg.ch4 %>%    #take 
  mutate(source="Cape Grim CH4") %>%  
  dplyr::select(date, cdate, lag.grad, source ) %>%
  mutate(lag.grad=lag.grad*10) %>%
  rbind(us.gas %>% 
          mutate(source="US gas production" ) %>%   #offset here
          dplyr::select(date,cdate, lag.grad, source)
  ) %>%
  dplyr::rename(trend.grad=lag.grad),

#my.date <- ymd("1999-07-01")
#my.year <- year(my.date)

cg.ch4.spread  =cg.us %>% 
  dplyr::select(date=cdate, trend.grad, source) %>% 
  #  subset( date < ymd("2015-04-01")) %>% 
  spread(source, trend.grad) %>% 
  rename( cape.grim=`Cape Grim CH4`, US.gas=`US gas production`) %>% 
  mutate(factor= cut(date,c(ymd("1900-1-01"), ymd("2000-01-01") ,ymd("2100-1-01")), labels=c("pre","post"))) ,
# cg.ch4.spread$factor <- paste0("pre:", my.year)
# cg.ch4.spread$factor[cg.ch4.spread$date > my.date] <- paste0("post:", my.year)


#cg.ch4.spread$factor[cg.ch4.spread$date>=ymd("2000-01-01")] <-"post"
  #merged.data =merge(x,y)
  p007= plots(cg.ch4,  cptfits, my.cpts, cg.ch4.cpt.groupings, my.cpt.data, 
              us.gas,
              us.cpt.groupings, cg.us )

)
