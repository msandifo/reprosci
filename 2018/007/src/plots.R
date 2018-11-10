library(ggplot2)
# --------------------
# ggplot routines
#---------------------
plots <- function(cg.ch4,
                   
                  cptfits, 
                  my.cpts,
                  cg.ch4.cpt.groupings,
                  m.data , 
                  us.gas,
                  us.cpt.groupings,
                  cg.us
) {

  print(my.cpts)
  p01 <-ggplot(data=cg.ch4,  aes(date, value)) +
      geom_line(size=.2, aes( linetype=source ))+
      geom_line(aes(y=trend), colour="red")+
      scale_colour_manual(values=c("black", "black"))+
      theme(legend.position=c(.15,.85))+
      labs(y="Cape Grim methane concentration - ppb", 
           x=NULL,
           subtitle= "the methane enigma #1",
           caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/007"
           )
   
  
  p01a <- p01  + 
      geom_vline(xintercept=my.cpts$date , size=.1, colour="grey50", linetype=1 )+
      geom_point(data=cg.ch4.cpt.groupings, colour="white", size=3 )+
      geom_point(data=cg.ch4.cpt.groupings, colour="black" )+
      geom_text( data=my.cpts, colour="black" ,  aes(x=date,y=1585, label=labels ), size=2.2, angle=90,vjust=-.5)+
      ggrepel::geom_label_repel(data=cg.ch4.cpt.groupings, colour="black" , aes(x=date,y=value+3, label=nlabels), 
                                nudge_y=40,nudge_x=.55,fill="white", size=2.2,  segment.size=.15)+
    labs(  subtitle= "the methane enigma #1a"  )+
    theme(legend.position = NULL)
  
  
  

  p02 = ggplot(data=us.gas,  aes(date, value/1e6)) +
    geom_line(size=.2)+
    geom_line(aes(y=trend/1e6), colour="red")+
    scale_colour_manual(values=c("black", "black"))+
    theme(legend.position=c(.15,.85))+
    labs(x=NULL, y= "US natural gas production\ntrillion cubic feet per month",
         subtitle= "the methane enigma #2",
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/007"
    ) 
  
   
   
  
  p02a =   p02 +  
      geom_vline(xintercept=my.cpts$date , size=.1, colour="grey50", linetype=1)+
      geom_point(data=us.cpt.groupings, colour="white", size=3 )+
      geom_point(data=us.cpt.groupings, colour="black" )+
      geom_text( data=my.cpts, colour="black" ,  aes(x=date,y=1.585, label=labels ), size=2.2, angle=90,vjust=-.5)+
      ggrepel::geom_label_repel(data=us.cpt.groupings, colour="black" , aes(x=date,y=value/1e6+.015, label=nlabels),
                                nudge_y=.2,fill="white", size=2.2, segment.size=.25)+
      labs( subtitle= "the methane enigma #2a")
         
  
   
  
  p03<-ggplot(cg.us %>% subset(cdate>dmy("01-11-2000") & !is.na(date)) , 
              aes(date, trend.grad, colour=source))+
      geom_smooth(span=.165, se=T, size=0, alpha=.5,   aes(  fill=source), show.legend = F)+
      geom_line(size=.1) +
      geom_point(size=.7, colour="white") +
      geom_point(size=.5) +
      theme(legend.position=c(.2,.925))+
      guides(  colour = guide_legend( title = NULL))+
      scale_colour_manual(values =c("royalblue4","firebrick2"))+
      scale_fill_manual(values =c("royalblue4","firebrick2"))+
      scale_y_continuous(labels = signif_scale, 
                         sec.axis = sec_axis(~./10,  
                                             "Cape Grim CH4 growth rate\ndeseasonalised and annualised", 
                                             labels = signif_scale))+
      labs(title=NULL,
           subtitle= "the methane enigma #3",
           x=NULL,          
           caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/007",
           y ="US natural gas production growth rate\ndeseasonalised and annualised")+
    theme(axis.text.y.right = element_text(color = "royalblue4"),
          axis.title.y= element_text(  color = "firebrick2"),
          axis.text.y= element_text(  color = "firebrick2"),                   
          axis.title.y.right= element_text(angle = -90,   color = "royalblue4"))
           
  p04= ggplot(m.data , 
              aes(trend.grad.x, trend.grad.y, colour=grouping,label=range, fill=grouping))+
    geom_smooth(method="lm", alpha=.1, fullrange=T, size=.2)+
    ggrepel::geom_text_repel(nudge_y=1, size=2.5, segment.size=.25 )+
    geom_point(size=4, colour="white")+
    geom_point(size=3.3)+
    scale_colour_manual(values =c("royalblue4","firebrick2"))+
    scale_fill_manual(values =c(  "royalblue4","firebrick2"))+
    theme(legend.position="none")+
    labs( subtitle= "the methane enigma #4",
                 x="Cape Grim growth rate\nannualised",
                 y="US natural gas growth rate\nannualised ",
                 caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci/tree/master/2018/007") +
    geom_text( data=my.cpt.data[1,], x=.05, y=7.5, 
               label= paste0("2000+ , r-squared = ",  round(cptfits[[2]],2)) , 
               colour="firebrick2",
               size=5, 
               hjust=0 )+
    geom_text( data=my.cpt.data[1,], x=.05, y=8.5, 
               label= paste0("2000-, r-squared = ",  round(cptfits[[1]],2)) , 
               colour="royalblue4",
               size=5, 
               hjust=0 )+
    coord_cartesian(ylim=c(-1,9))
  
return (list(p1=p01, p1a=p01a, p2=p02 ,p2a=p02a, p3=p03, p4=p04))
}