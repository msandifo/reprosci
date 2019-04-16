library(ggplot2)
# --------------------
# ggplot routines
#---------------------
plots <- function(merged.data, i.data) {

  
  reproscir::theme_twitter()
  l.cols<- c("blue3","firebrick2")
  
  p01 <- ggplot(merged.data, aes(year, ff.prod.mtoe - ff.cons.mtoe , colour=region ))+
    geom_line()+
    scale_color_manual(values=l.cols)+
    labs(y= "annual fossil export\nmtoe", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/005")+
    theme(legend.position = c(.2,.9), legend.title = element_blank())
  
  p02 <-ggplot(merged.data, aes(year, (ff.prod.mtoe - ff.cons.mtoe)/LP  , colour=region ))+
    geom_line()+
    scale_color_manual(values=l.cols)+
    labs(y= " fossil export\nmtoe per capita", x=NULL,
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/005")+
    theme(legend.position = c(.1,.9), legend.title = element_blank())
  
  
  p03 <-ggplot(merged.data, aes(year, GGXCNL*US.exchange , colour=region ))+
    geom_line()+
    scale_color_manual(values=l.cols)+
    labs(y= "net government revenue balance GGXCNL, 1990+\nUS$'billions", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/005")+
    theme(legend.position = c(.2,.9), legend.title = element_blank())
  
  p04 <- ggplot(merged.data, aes(year, (GGXONLB-GGXCNL)*US.exchange  , colour=region ))+
    geom_line()+
    scale_color_manual(values=l.cols)+
    labs(y= "interest payable/paid GGXONLB-GGXCNL, 1990+\nUS$'billions", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/005")+
    theme(legend.position = c(.2,.9), legend.title = element_blank())+
    theme(legend.position = c(.2,.9), legend.title = element_blank())
  
  
  p05 <-ggplot(merged.data, aes(year, GGXCNL.cum*US.exchange , colour=region ))+
    geom_line()+
    scale_color_manual(values=l.cols)+
    labs(y= "Cumulative net lending/borrowing, GGXCNL, 1990+\nUS$'billions", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/005")+
    theme(legend.position = c(.2,.9), legend.title = element_blank())
  
  
  p06 <-ggplot(merged.data, aes(year, GGXCNL.cum*US.exchange/LP, colour=region ))+
    geom_line()+
    scale_color_manual(values=l.cols)+
    labs(y= "Cumulative per.capita net revenue balance, GGXCNL, 1990+\nUS$'000s", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/005")+
    theme(legend.position = c(.2,.9), legend.title = element_blank())
  
  
  p07 <- ggplot(merged.data, aes(year, US.exchange , colour=region ))+
    geom_line()+
    scale_color_manual(values=l.cols)+
    labs(y= " local currency - US$ exchange", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/005")+
    theme(legend.position = c(.2,.9), legend.title = element_blank())
  
  
  imf.data.aus =   subset( i.data,region == "Australia"  ) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(year)
  
  imf.data.aus$gov = "Labor"
  imf.data.aus$gov[imf.data.aus$year>1996] = "Coalition"
  imf.data.aus$gov[imf.data.aus$year>2007] = "Labor"
  imf.data.aus$gov[imf.data.aus$year>2013] = "Coalition"
  imf.data.aus$p = "1"
  imf.data.aus$p[imf.data.aus$year>1996] = "2"
  imf.data.aus$p[imf.data.aus$year>2007] = "3"
  imf.data.aus$p[imf.data.aus$year>2013] = "4"
  
  print(imf.data.aus)
  imf.data.sums <- imf.data.aus  %>% dplyr::group_by(p)  %>% 
    dplyr::summarise(GGXCNL.cum =round(tail(GGXCNL.cum,1),0), y=GGXCNL.cum, year=tail(year,1),  gov=tail(gov,1))
  
  
  p08 =  ggplot(imf.data.aus, aes(year+.5, GGXCNL.cum, group=p, col=gov, fill=gov, shape=gov))+
    geom_vline(xintercept = c( 1991.9, 2008.8), col="grey30", linetype=2, size=.2)+
    geom_smooth( method = "loess", size=0.35, se=F)+
    geom_point(colour="white", size=3.5)+
    annotate("text", x=1992, y=-300, label="Keating 'the recession\nwe had to have'", size=3, hjust=0, col="black", fontface ="italic")+
    annotate("text", x=2009, y=-300, label="the \nGFC", size=3, hjust=0, col="black", fontface ="italic")+
    geom_point(size=2)+
    scale_color_manual(values=l.cols)+
    geom_text(data= imf.data.sums, aes(year+1.5,y=y+20, label= paste0("$",GGXCNL.cum, " bil.")), size=3, show.legend = F)+
    
    labs(subtitle = "budget repair, #01\ntell them they're dreaming ..." ,
         y= "Net Aus. gov. lending/borrowing, GGXCNL\nA$'billions", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/005")+
    theme(legend.position = c(.3,.2), legend.title = element_blank())
   
  
  imf.data.diff.aus = tail(imf.data.aus,-1)
  imf.data.diff.aus$GGXCNL.cum =  diff(imf.data.aus$GGXCNL.cum ) 
  
  imf.data.diff.aus.pos <- imf.data.diff.aus
  imf.data.diff.aus.neg <- imf.data.diff.aus 
  imf.data.diff.aus.neg$GGXCNL.cum[imf.data.diff.aus.neg$GGXCNL.cum >0] <-0
  imf.data.diff.aus.pos$GGXCNL.cum[imf.data.diff.aus.pos$GGXCNL.cum <0] <-0
  # imf.data.diff.aus.pos$p <- 1
  # imf.data.diff.aus.neg$p <- 1
  
  
  imf.data.diff.sums <- imf.data.diff.aus %>% head(-1) %>% dplyr::group_by(p)  %>% 
    dplyr::summarise(GGXCNL=round(sum(GGXCNL.cum),0), GGXCNL.cum =round(mean(GGXCNL.cum),0), 
                     y=mean(GGXCNL.cum), yearm=mean(year), year=tail(year,1),  gov=tail(gov,1))
  
  print(imf.data.diff.sums)
  p09 = ggplot(imf.data.diff.aus %>% head(-1), aes(year+.5, GGXCNL.cum, group=p, col=gov, fill=gov, shape=gov))+
    geom_area(data= imf.data.diff.aus.pos %>% head(-1) , aes(year+.5, GGXCNL.cum), fill="grey30",alpha=.15, size=0, show.legend = F)+
    geom_area(data= imf.data.diff.aus.neg %>% head(-1) , aes(year+.5, GGXCNL.cum), fill="red3",alpha=.25, size=0, show.legend=F)+
    geom_smooth( method = "loess", size=2.5, se=F, span=.52, col="white")+
    geom_smooth( method = "loess", size=0.5, se=F, span=.52)+
    geom_vline(xintercept = c( 1991.9, 2008.8), col="grey30", linetype=2, size=.2)+
    geom_hline(yintercept = c(0), col="grey30", linetype=2, size=.2)+
    geom_smooth( method = "lm", formula = y~1,size=.35, se=F, level=.2 , show.legend = F)+
    geom_point(colour="white", size=3.5)+
    geom_point(size=2)+
    geom_text(data= imf.data.diff.sums, aes(year+1,y=y, label=GGXCNL.cum), size=3, show.legend = F)+
    geom_text(data= imf.data.diff.sums, aes(yearm+.5,y=GGXCNL.cum/1.8, label=paste0("$",GGXCNL, " bil.")), size=3, show.legend = F)+
    scale_color_manual(values=l.cols)+
    annotate("text", x=1992, y=15, label="Keating 'the recession\nwe had to have'", size=3, hjust=0, col="black", fontface ="italic")+
    annotate("text", x=2009, y=15, label="the \nGFC", size=3, hjust=0, col="black", fontface ="italic")+
    annotate("text", x=2016, y=2.5, label="annual surplus", size=3, hjust=0, col="black", fontface ="italic")+
    annotate("text", x=2016, y=-2, label="annual deficit", size=3, hjust=0, col=l.cols[2], fontface ="italic")+
    labs(subtitle = "budget repair, #02\ntell them they're dreaming ..." ,
         y= "Annual Aus. gov. lending/borrowing\nA$'billions", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/005")+
    theme(legend.position = c(.3,.2), legend.title = element_blank())
  
  labor.proj = data.frame(x=c(2010.5, 2018.5), 
                            y= c(imf.data.diff.aus$GGXCNL.cum[imf.data.diff.aus$year==2010], 
                                 imf.data.diff.aus$GGXCNL.cum[imf.data.diff.aus$year==2013]*2- 
                                   5/4*(imf.data.diff.aus$GGXCNL.cum[imf.data.diff.aus$year==2010])))
 
coalition.proj = data.frame(x=c(2017, 2022), 
                          y= c(imf.data.diff.aus$GGXCNL.cum[imf.data.diff.aus$year==2016], 
                               imf.data.diff.aus$GGXCNL.cum[imf.data.diff.aus$year==2018]*2- 
                                 4.25/3*(imf.data.diff.aus$GGXCNL.cum[imf.data.diff.aus$year==2016])))
  
  labor.proj$p<-3
  labor.proj$gov<-"Labor"
  print(labor.proj) 
  coalition.proj$p<-3
  coalition.proj$gov<-"Coalition"
  print(labor.proj) 
  
 
 p10 = ggplot(imf.data.diff.aus %>% head(-1), aes(year+.5, GGXCNL.cum, group=p, col=gov, fill=gov, shape=gov))+
    geom_area(data= imf.data.diff.aus.pos %>% head(-1) , aes(year+.5, GGXCNL.cum), fill="grey30",alpha=.15, size=0, show.legend = F)+
    geom_area(data= imf.data.diff.aus.neg %>% head(-1) , aes(year+.5, GGXCNL.cum), fill="red3",alpha=.25, size=0, show.legend=F)+
   geom_smooth( method = "loess", size=2.5, se=F, span=.52, col="white")+
    geom_smooth( method = "loess", size=0.5, se=F, span=.52)+
   geom_line(data= labor.proj, aes(x,y),linetype=2, size=.25, arrow = arrow(length = unit(0.1, "cm")), show.legend = F)+
   geom_line(data= coalition.proj, aes(x,y),linetype=2, size=.25, arrow = arrow(length = unit(0.1, "cm")), show.legend = F)+
   geom_vline(xintercept = c( 1991.9, 2008.8), col="grey30", linetype=2, size=.2)+
    geom_hline(yintercept = c(0), col="grey30", linetype=2, size=.2)+
    geom_smooth( method = "lm", formula = y~1,size=.35, se=F, level=.2 , show.legend = F)+
    geom_point(colour="white", size=3.5)+
    geom_point(size=2)+
#   geom_text(data= imf.data.diff.sums, aes(year+1,y=y, label=GGXCNL.cum), size=3, show.legend = F)+
#    geom_text(data= imf.data.diff.sums, aes(yearm+.5,y=GGXCNL.cum/1.8, label=paste0("$",GGXCNL, " bil.")), size=3, show.legend = F)+
    scale_color_manual(values=l.cols)+
    annotate("text", x=1992, y=15, label="Keating 'the recession\nwe had to have'", size=3, hjust=0, col="black", fontface ="italic")+
    annotate("text", x=2009, y=15, label="the \nGFC", size=3, hjust=0, col="black", fontface ="italic")+
   #  annotate("text", x=2010, y=2.5, label="annual surplus", size=3, hjust=0, col="black", fontface ="italic")+
   #  annotate("text", x=2010, y=-2, label="annual deficit", size=3, hjust=0, col=l.cols[2], fontface ="italic")+
    annotate("text", x=2017.7, y=10, label="Labor's\nprojected\n net deficit\n ~$380 billion", size=3, hjust=0.5, col=l.cols[2], fontface ="italic")+
   annotate("text", x=2022, y=10, label="Coalition's\nprojected\n net deficit\n ~$570 billion", size=3, hjust=0.5, col=l.cols[1], fontface ="italic")+
   annotate("text", x=2020.25, y=-32, label="current\n net deficit\n $542 billion", size=3, hjust=0.5, col=l.cols[1], fontface ="italic")+
   labs(subtitle = "budget repair, #03\ntell them they're dreaming ..." ,
         y= "Annual Aus. gov. lending/borrowing\nA$'billions", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/005")+
    theme(legend.position = c(.3,.2), legend.title = element_blank())+xlim(c(1991.4, 2022.5))
  
  
return (list(p1=p01,p2=p02,p3=p03,p4=p04,p4=p04,p5=p05,p6=p06,p7=p07,p8=p08,p9=p09, p10=p10 ))
}
