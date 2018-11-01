library(ggplot2)
 # --------------------
# ggplot routines
#---------------------
plots <- function(m.data) {

  p01<-ggplot(m.data  , aes(x=1000*value/value.x ,y=perCap,  colour=region, label= round(perCap,1)))+ 
    geom_path(arrow = arrow(angle=25,length=unit(.081, "inches"),type = "closed"))+ 
    geom_point(data= m.data %>% subset(year==2009), colour="white", size=2)+
    geom_point(data= m.data %>% subset(year==2009), show.legend = F, size=1)+
    geom_text(data= m.data %>% subset(year==2017), size=4,
              show.legend = F, vjust=1. ,hjust=-.05  )+
    labs(y="Per capita energy sector emissions\ntonnes per year", 
         x= "Per Capita GDP-PPP",
         subtitle= 'data sourced from BP & IMF, 1980-2017',
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
    guides(colour=guide_legend(ncol=1 )) +
    theme(legend.position = c(.95, .75),  
          legend.text = element_text( size = 8),
          legend.key = element_rect(colour = "transparent", fill = "transparent"),
          legend.background = element_rect(fill="transparent", size=0., colour="transparent" ),
          legend.title = element_blank())+
    
    scale_x_continuous(labels = scales::dollar )
 # p01<- ggplot(m.data , aes(x=1000*value/value.x ,y=perCap,  colour=region, label= round(perCap,1)))+ 
 #    geom_path(arrow = arrow(angle=25,length=unit(.081, "inches"),type = "closed"))+ 
 #    geom_point(data= m.data %>% subset(year==2009), colour="white", size=2)+
 #    geom_point(data= m.data %>% subset(year==2009), show.legend = F, size=1)+
 #    geom_text(data= m.data %>% subset(year==2017), size=4,
 #              show.legend = F, vjust=1. ,hjust=-.05  )+
 #    labs(y="Per capita emissions - energy sector", 
 #         x= "Per Capita GDP-PPP", 
 #         title= paste('data sourced from BP & IMF,', max(m.data$year), "-", min(m.data$year),'inclusive'))+
 #    theme(legend.position = c(.9,.8),  legend.title = element_blank())+
 #    guides(colour=guide_legend(ncol=2,byrow=F)) +
 #    scale_x_continuous(labels = function(x) paste0("s",x) )
 #  

return (list(p1=p01 ))
}
