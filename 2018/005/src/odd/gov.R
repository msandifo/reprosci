countries=c(  "Australia"  )

measures =c("GGXCNL",  "GGXONLB","NGDPDPC","NGDPPC","LP" ) 
#measures =c("GGR", "GGX","GGXCNL","NGDPDPC","NGDPPC","LP" ),


imf.data = purrr::map2_df (rep(countries,each=length(measures)), 
                         rep(measures,length(countries)), 
                         reproscir::read_IMF, percent=F  )   %>%
  dplyr::mutate(year=as.numeric(year))%>%
  tidyr::spread( measure, value  ) %>% 
  dplyr::arrange(region, year) %>%
  subset(year>1987 & year<= 2019) %>%
  dplyr::group_by(region ) %>%
  # dplyr::mutate(GGR.cum=cumsum(GGR), GGX.cum=cumsum(GGX),GGXCNL.cum=cumsum(GGXCNL))
  dplyr::mutate( US.exchange=NGDPDPC/NGDPPC,GGXCNL.cum=cumsum(GGXCNL), GGXONLB.cum=cumsum(GGXONLB)) %>%
  dplyr::select(year, region,LP,US.exchange,GGXCNL, GGXCNL.cum, GGXONLB, GGXONLB.cum)

imf.data$gov <- "Labor"
imf.data$gov[imf.data$year>1996] <- "Coalition"
imf.data$gov[imf.data$year>2007] <- "Labor"
imf.data$gov[imf.data$year>2013] <- "Coalition"
imf.data$p <- "1"
imf.data$p[imf.data$year>1996] <- "2"
imf.data$p[imf.data$year>2007] <- "3"
imf.data$p[imf.data$year>2013] <- "4"

ggplot(imf.data, aes(year+.5, GGXCNL.cum  , group=p, col=gov, fill=gov, shape=gov))+
  geom_vline(xintercept = c( 1991.9, 2008.8), col="grey30", linetype=2, size=.3)+
  geom_smooth( method = "loess", size=0.5, se=F)+
  geom_point(colour="white", size=3.5)+
  geom_point(size=2.5)+
  scale_color_manual(values=c("blue3","firebrick2"))+
  labs(y= "Cumulative net government lending/borrowing, GGXCNL\nA$'billions", x=NULL,         
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
  theme(legend.position = c(.3,.2), legend.title = element_blank())
ggsave("~/Desktop/gov.png", width=8,height=5 )



 
imf.data.diff <- tail(imf.data,-1)
imf.data.diff$GGXCNL.cum = diff(imf.data$GGXCNL.cum ) 

ggplot(imf.data.diff %>% head(-1), aes(year+.5, GGXCNL.cum, group=p, col=gov, fill=gov, shape=gov))+
  geom_smooth( method = "loess", size=0.5, se=F, span=.52)+
  geom_vline(xintercept = c( 1991.9, 2008.8), col="grey30", linetype=2, size=.3)+
  geom_smooth( method = "lm", formula = y~1,size=1.5, se=F, level=.2 , show.legend = F)+
  geom_point(colour="white", size=3.5)+
  geom_point(size=2.5)+
  scale_color_manual(values=c("blue3","firebrick2"))+
  labs(y= "Change in  net government lending/borrowing\nA$'billions", x=NULL,         
       caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
  theme(legend.position = c(.3,.2), legend.title = element_blank())

ggsave("~/Desktop/gov_diff.png", width=8,height=5 )



