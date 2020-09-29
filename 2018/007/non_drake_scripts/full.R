source('./src/settings.R')
source('./src/packages.R')
source('./src/theme.R')
source('./src/functions.R')
source('./src/downloads.R')
if (file.exists('./src/plots.R')) source('./src/plots.R')
if (file.exists('./src/tables.R')) source('./src/tables.R')
if (file.exists('./src/reports.R')) source('./src/reports.R')
if (!exists("do.plots")) do.plots=F
if (!exists("do.updates")) do.updates=F

cg.ch4= reproscir::read_data("cape.grim.ch4", data=T)  %>% 
  mutate(cdate=date, date=decimal_date(date)) %>%  
  
  subset(source != "Cape Grim air archive") %>%
  mutate(trend = (decompose(ts(value, frequency=12)))$trend %>% 
           as.numeric(  optional=T),
         trend.grad = 12* (c(NA, diff( trend)/tail( trend, -1))+
                             c( diff( trend)/head( trend, -1), NA))/2  )# %T>% glimpse()
# mutate( mutate( cdate = dmy(paste0("15-", month(date_decimal(date)),"-", year(date_decimal(date)) )))  -> 

#  library(readxl)
us.gas = reproscir::read_data("eia.us.ng.withdrawals", data=T)[,c(1,3)] %>% 
  dplyr::mutate(cdate=as.Date(date), date=decimal_date(date), value=us) %>%  
  #   cdate = dmy(paste0("15-", month(date_decimal(date)),"-", year(date_decimal(date)) )) )  %>% 
  dplyr::select(date, cdate,value) %>%  
  subset(date > min(cg.ch4$date) & date<= max(cg.ch4$date) ) %>%
  dplyr::mutate(trend = (decompose(ts(value, frequency=12)))$trend %>% 
                  as.numeric(  optional=T),
                trend.grad = 12* (c(NA, diff( trend)/tail( trend, -1))+
                                    c( diff( trend)/head( trend, -1), NA))/2 ) %>%
  rename(cdate=2,us=3)  %>%
  dplyr::mutate( value=us) %>%  
  #   cdate = dmy(paste0("15-", month(date_decimal(date)),"-", year(date_decimal(date)) )) )  %>% 
  dplyr::select(date, cdate,value) %>%  
  subset(date > min(cg.ch4$date) & date<= max(cg.ch4$date) ) %T>%
  glimpse() %>%
    dplyr::mutate(trend = (decompose(ts(value, frequency=12)))$trend %>% 
                  as.numeric(  optional=T),
                trend.grad = 12* (c(NA, diff( trend)/tail( trend, -1))+
                                    c( diff( trend)/head( trend, -1), NA))/2 )

 
#  library(readxl)
us.rig.count= reproscir::read_data("bh.rc.bytrajectory", data=T)  %>% 
  # mutate(date=decimal_date(date)) %>% 
  dplyr::select(1:4) %>% 
  tidyr::gather(  type, value,  -date)   %>% 
  mutate(cdate=date, date=decimal_date(date))  


us.gas.info =reproscir::get_info("ei.us.ng.withdrawals")
cg.ch4.info= reproscir::get_info("cape.grim.ch4")


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
nq = 13 # number of changepoints
minseg = 12 #nu,ber of months
cg.ch4.narm = cg.ch4[ !is.na(cg.ch4$trend.grad),]#remove NA's
my.cpt =  changepoint::cpt.mean( cg.ch4.narm$trend.grad , penalty="Manual",
                                 pen.value=0.025,
                                 method="BinSeg",
                                 Q=nq,
                                 test.stat="Normal",
                                 class=TRUE,
                                 param.estimates=TRUE,
                                 minseglen=minseg)
#--------
# get us change point 1. Q-> 1
#--------
us.gas.narm = us.gas[ !is.na(us.gas$trend.grad),] #remove NA's
us.gas.cpt =  changepoint::cpt.mean( us.gas.narm$trend.grad , penalty="Manual",
                                     pen.value=0.025,
                                     method="BinSeg",
                                     Q=1,
                                     test.stat="Normal",
                                     class=TRUE,
                                     param.estimates=TRUE,
                                     minseglen=minseg)

# sets our refernce time less one year
us.gas.date = unique(us.gas.narm$cdate[us.gas.cpt@cpts.full])
my.date = us.gas.date  #-years(1) #ymd("2003-01-01")


my.cpts.inds = sort(unique(as.numeric(my.cpt@cpts.full)))
my.cpts  = tibble(cdate=cg.ch4.narm$cdate[my.cpts.inds] ) %>% 
  mutate(date =decimal_date(cdate),
         labels=format(cdate,  "%b %Y") ) 
my.cpt.dates = cg.ch4.narm$cdate[my.cpts.inds] 

my.cpt.ranges =  c(paste0( "< ", head(my.cpts$labels,1) ), 
                   paste0(head(my.cpts$labels,-1), " -\n", tail(my.cpts$labels,-1)),
                   paste0( "> ", tail(my.cpts$labels,1) ))

annual.percentage.factor = 100 # annual percentage rise...

cg.ch4.cpt.groupings = add_cpt_groups(cg.ch4, my.cpt.dates, col="cdate") %>% 
  group_by(group) %>% 
  dplyr::summarise(date=mean(date), 
                   cdate=mean(cdate), 
                   value=mean(value), 
                   trend.grad=annual.percentage.factor*mean(trend.grad, na.rm=T) ) %>%
  dplyr::mutate(range= my.cpt.ranges ,  
                labels=paste0(round(trend.grad,2), "% p.a."),
                nlabels=paste0(round(trend.grad,2),"%" ))
#write_csv(cg.ch4.cpt.groupings[, c(1,3,4,5)])


us.cpt.groupings = add_cpt_groups(us.gas, my.cpt.dates, col="cdate") %>% 
  group_by(group) %>% 
  dplyr::summarise(date=mean(date), 
                   cdate=mean(cdate), 
                   value=mean(value), 
                   trend.grad=annual.percentage.factor*mean(trend.grad, na.rm=T) ) %>%
  mutate(range= my.cpt.ranges ,  
         labels=paste0(round(trend.grad,2), "% p.a."),
         nlabels=paste0(round(trend.grad,2),"%" )) %T>% glimpse()



# my.cpt.data = merge(cg.ch4.cpt.groupings[, c(3,5, 6)], us.cpt.groupings[, c(5, 6)], by="range") %>% arrange(cdate) %>%
#   mutate(grouping= cut(cdate,c(ymd("1900-1-01"), my.date ,ymd("2015-04-01"),ymd("2100-1-01")), labels=c("pre","post","last"))),

my.cpt.data = merge(cg.ch4.cpt.groupings[, c(3,5, 6)], us.cpt.groupings[, c(5, 6)], by="range") %>%
  arrange(cdate) %>%
  mutate(grouping = cut(cdate,c(ymd("1900-1-01"), ymd("2000-01-01"), ymd("2100-1-01")), labels=c("pre","post")))

cpt.models = my.cpt.data %>%
  split(.$grouping) %>%
  map(~lm(.$trend.grad.x ~ .$trend.grad.y, data=. ))

cptfits =cpt.models %>% map(summary) %>%  map_dbl(~.$r.squared)   


cg.us=cg.ch4 %>%    #take 
  mutate(source="Cape Grim CH4") %>%  
  dplyr::select(date, cdate, trend.grad, source ) %>%
  mutate(trend.grad=trend.grad*10) %>%
  rbind(us.gas %>% 
          mutate(source="US gas production" ) %>%   #offset here
          dplyr::select(date,cdate, trend.grad, source)
  ) 

#my.date <- ymd("1999-07-01")
#my.year <- year(my.date)

cg.ch4.spread  =cg.us %>% 
  dplyr::select(date=cdate, trend.grad, source) %>% 
  #  subset( date < ymd("2015-04-01")) %>% 
  spread(source, trend.grad) %>% 
  rename( cape.grim=`Cape Grim CH4`, US.gas=`US gas production`) %>% 
  mutate(factor= cut(date,c(ymd("1900-1-01"), ymd("2000-01-01") ,ymd("2100-1-01")), labels=c("pre","post")))
# cg.ch4.spread$factor <- paste0("pre:", my.year)
# cg.ch4.spread$factor[cg.ch4.spread$date > my.date] <- paste0("post:", my.year)


#cg.ch4.spread$factor[cg.ch4.spread$date>=ymd("2000-01-01")] <-"post"
#merged.data =merge(x,y)
p007= plots(cg.ch4,  cptfits, my.cpts, cg.ch4.cpt.groupings, my.cpt.data, 
            us.gas,
            us.cpt.groupings, cg.us )

if (do.plots) {
  ggsave('./figs/p007_01.png',  p007$p1 ,width=8, height=5)
ggsave('./figs/p007_02.png',  p007$p2 ,width=8, height=5)
ggsave('./figs/p007_03.png',  p007$p3 ,width=8, height=5)
ggsave('./figs/p007_03a.png',  p007$p3a ,width=8, height=5)

ggsave('./figs/p007_04.png',  p007$p4 ,width=8, height=5)
ggsave('./figs/p007_01a.png',  p007$p1a ,width=8, height=5)
ggsave('./figs/p007_02a.png',  p007$p2a ,width=8, height=5)
}
if (do.updates) reproscir::update_data("noaa.monthly.CGO.c13")
cg.c13=reproscir::read_data("noaa.monthly.CGO.c13", data=T)  %>% 
  mutate(cdate=date, date=decimal_date(date)) %>%  
  
 reproscir::add_trends(order=24,index=3 )#
#
names(cg.c13)

library(ggtext) #remotes::install_github("clauswilke/ggtext")
(p05= ggplot(cg.c13 %>% subset(cdate>dmy("01-11-2000") & !is.na(date)) , 
             aes(date, value ))+
  geom_smooth(span=.3, se=T, size=0, alpha=.25, fill="firebrick3",   show.legend = F)+
  geom_line(size=.1, colour="firebrick3") +
    geom_line(  aes(y=trend),colour="firebrick3", size=1.2) +
    geom_point(size=.7, colour="white") +
  geom_point(size=.5,colour= "firebrick3") +
  theme(legend.position=c(.2,.925))+
  guides(  colour = guide_legend( title = NULL))+
  scale_colour_manual(values =c( "firebrick2"))+
  scale_fill_manual(values =c( "firebrick2"))+
   
  labs(title=NULL,
       subtitle= "the methane enigma #5",
       x=NULL,          
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/007",
       y =  "*&delta;*<sup>13</sup>C<sub>CH<sub>4</sub></sub> (&permil; PDB)") +
    theme(
      axis.title.x = element_markdown(),
      axis.title.y = element_markdown()
    )
)

(p05a= ggplot(cg.c13 %>% subset(cdate>dmy("01-11-2000") & !is.na(date)) , 
             aes(date, trend.grad*1000))+
    geom_smooth(span=.25, se=T, size=0, alpha=.25, fill="firebrick3",   show.legend = F)+
    geom_line(size=.1, colour="firebrick3") +
    geom_point(size=.7, colour="white") +
    geom_point(size=.5,colour= "firebrick3") +
    theme(legend.position=c(.2,.925))+
    guides(  colour = guide_legend( title = NULL))+
    scale_colour_manual(values =c( "firebrick2"))+
    scale_fill_manual(values =c( "firebrick2"))+
    
    labs(title=NULL,
         subtitle= "the methane enigma #5a",
         x=NULL,          
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/007",
         y =  "*&Delta;(*&delta;*<sup>13</sup>C<sub>CH<sub>4</sub></sub> )")  +
    theme(
      axis.title.x = element_markdown(),
      axis.title.y = element_markdown()
    )
)
if (do.plots) ggsave('./figs/p007_05.png',  p05 ,width=8, height=5)

if (do.updates) reproscir::update_data("bh.rc.bytrajectory")
(p06<-reproscir::read_data("bh.rc.bytrajectory", data=T)[,1:4] %>%
  gather(   type, value,  -date) %>%
  subset(type=="horz") %>%
  ggplot(  aes(date,value, fill=type))+geom_area( )+
  labs(subtitle="US rig count",
       caption=paste("data sourced from Baker-Hughes,", 
                     tail(reproscir::read_data("bh.rc.bytrajectory", data=T)[,1],1)),
       x=NULL,
       y ="number of horizontalrigs")+
  theme(legend.position =  "None")+#, c(.125,.85), legend.direction="vertical")+
  guides(   fill = guide_legend( title = NULL))+
  scale_x_date(expand = c(0.01,0) , limits = ymd("2000-01-01", "2020-02-01"))+
  scale_y_continuous(limits = c(0.,1500), expand=c(0,0) )+
  scale_fill_manual(values =c( "firebrick2","green4" )) 
)

if (do.plots) ggsave('./figs/p007_06.png',  p06 ,width=8, height=5)
