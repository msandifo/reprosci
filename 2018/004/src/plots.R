library(ggplot2)
 # --------------------
# ggplot routines
#---------------------
plots <- function(m.data) {

  p01<-ggplot(m.data  , aes(x=1000*gdp/pop ,y=perCap,  colour=region, label= round(perCap,1)))+ 
    geom_path(arrow = arrow(angle=25,length=unit(.081, "inches"),type = "closed"))+ 
    geom_point(data= m.data %>% subset(year==2009), colour="white", size=2)+
    geom_point(data= m.data %>% subset(year==2009), show.legend = F, size=1)+
    geom_text(data= m.data %>% subset(year==2017), size=4,
              show.legend = F, vjust=1. ,hjust=-.05  )+
    labs(y="Per capita energy sector emissions\ntonnes per year", 
         x= "Per Capita GDP-PPP",
         subtitle= 'Energy sector data sourced from BP, population from IMF',
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
    guides(colour=guide_legend(ncol=1 )) +
    theme(legend.position = c(.95, .75),  
          legend.text = element_text( size = 8),
          legend.key = element_rect(colour = "transparent", fill = "transparent"),
          legend.background = element_rect(fill="transparent", size=0., colour="transparent" ),
          legend.title = element_blank())+
    
    scale_x_continuous(labels = scales::dollar ) 
  
   print (head(m.data))
  m.data %>% subset(region %ni% c("Indonesia",   "India")) -> m.filt.data 
  
  
  m.filt.data.ref = m.data %>% subset(year>2004 & region %ni% c("China", "Indonesia",   "India")) %>% 
    dplyr::group_by(region ) %>%
    dplyr::mutate(year=year,perCap=perCap/head(perCap,1)*100 , co2=co2/head(co2,1)*100) 
    
  
 p02<-ggplot( m.filt.data.ref, aes(x=year ,y=perCap,  colour=region,  label= paste0(round(perCap,0), "%")))+ 
      geom_path(arrow = arrow(angle=25,length=unit(.081, "inches"),type = "closed"))+ 
      geom_point(data=  m.filt.data.ref %>% subset(year==2009), colour="white", size=2)+
      geom_point(data=  m.filt.data.ref %>% subset(year==2009), show.legend = F, size=1)+
      geom_text(data= m.filt.data.ref %>% subset(year==2017), aes(x=2017.2),size=4,
                show.legend = F,
                hjust = 0 
                #label.size=0  
                #  fontface = 'bold', 
                #color = 'white',
                # box.padding = unit(0.35, "lines"),
                # point.padding = unit(0.75, "lines")
      )+
      labs(y="% change per capita energy sector emissions\n relative to 2005",x=NULL, 
           subtitle= 'Energy sector data sourced from BP, population from IMF',
           caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
    guides(colour=guide_legend(ncol=2 )) +
    theme(legend.position = c(.19, .25),  
         legend.text = element_text( size = 12),
         legend.key = element_rect(colour = "transparent", fill = "transparent"),
         legend.background = element_rect(fill="transparent", size=0., colour="transparent" ),
         legend.title = element_blank())+
   scale_x_continuous(limits=c(2005,2017.25),  breaks=seq(2005, 2017,2))
 
 
 
p03 <-ggplot( m.filt.data.ref, aes(x=year ,y=co2,  colour=region,  label= paste0(round(co2,0), "%")))+ 
     geom_path(arrow = arrow(angle=25,length=unit(.081, "inches"),type = "closed"))+ 
     geom_point(data=  m.filt.data.ref %>% subset(year==2009), colour="white", size=2)+
     geom_point(data=  m.filt.data.ref %>% subset(year==2009), show.legend = F, size=1)+
     geom_text(data= m.filt.data.ref %>% subset(year==2017) %>% dplyr::mutate(co2 = ifelse(region %in% c("Japan","Germany"),NA, co2 )),
               aes(x=2017.1), size=4,
               show.legend = F, 
               hjust=0
               #  
               #  fontface = 'bold' 
               #color = 'white',
               # box.padding = unit(0.15, "lines"),
               # point.padding = unit(0.5, "lines")
     )+
     labs(y="% change energy sector emissions\n relative to 2005",x=NULL, 
          subtitle= 'Energy sector data sourced from BP',
          caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
     theme(legend.position = "bottom",  legend.title = element_blank())+
     guides(colour=guide_legend(nrow=1,byrow=TRUE))  +
     guides(colour=guide_legend(ncol=2 )) +
     theme(legend.position = c(.19, .25),  
        legend.text = element_text( size = 12),
        legend.key = element_rect(colour = "transparent", fill = "transparent"),
        legend.background = element_rect(fill="transparent", size=0., colour="transparent" ),
        legend.title = element_blank())+
     scale_x_continuous(limits=c(2005,2017.25),  breaks=seq(2005, 2017,2))
 

p04= reproscir::plot_IMF_BP(percent=F)$p1+labs(  
                                        subtitle= 'Total World',
                                  caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")
  
  
p05= reproscir::plot_IMF_BP("Australia", percent=T)$p1+labs(   subtitle= 'Australia',
                                         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")
p06= reproscir::plot_IMF_BP("US", percent=T)$p1+labs(     subtitle= 'United States',
                                                               caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")


 #  

return (list(p1=p01, p2=p02, p3=p03, p4=p04, p5=p05, p6=p06 ))
}
