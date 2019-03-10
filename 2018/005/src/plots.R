library(ggplot2)
# --------------------
# ggplot routines
#---------------------
plots <- function(m.data, i.data) {

  
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
  
  p08 =  ggplot(imf.data.aus, aes(year+.5, GGXCNL.cum  , group=p, col=gov, fill=gov, shape=gov))+
    geom_vline(xintercept = c( 1991.9, 2008.8), col="grey30", linetype=2, size=.2)+
    geom_smooth( method = "loess", size=0.35, se=F)+
    geom_point(colour="white", size=2.5)+
    geom_point(size=1.5)+
    scale_color_manual(values=l.cols)+
    labs(subtitle = "budget repair, #01",
         y= "Cumulative net Aus. gov. lending/borrowing, GGXCNL\nA$'billions", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/005")+
    theme(legend.position = c(.3,.2), legend.title = element_blank())
   
  
  imf.data.diff.aus = tail(imf.data.aus,-1)
  imf.data.diff.aus$GGXCNL.cum =  diff(imf.data.aus$GGXCNL.cum ) 
  

  p09 = ggplot(imf.data.diff.aus %>% head(-1), aes(year+.5, GGXCNL.cum, group=p, col=gov, fill=gov, shape=gov))+
    geom_smooth( method = "loess", size=0.5, se=F, span=.52)+
    geom_vline(xintercept = c( 1991.9, 2008.8), col="grey30", linetype=2, size=.2)+
    geom_smooth( method = "lm", formula = y~1,size=1., se=F, level=.2 , show.legend = F)+
    geom_point(colour="white", size=2.5)+
    geom_point(size=1.5)+
    scale_color_manual(values=l.cols)+
    labs(subtitle = "budget repair, #02" ,
         y= "Change in  net Aus. gov. lending/borrowing\nA$'billions", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/005")+
    theme(legend.position = c(.3,.2), legend.title = element_blank())
  
  
  
return (list(p1=p01,p2=p02,p3=p03,p4=p04,p4=p04,p5=p05,p6=p06,p7=p07,p8=p08,p9=p09 ))
}
