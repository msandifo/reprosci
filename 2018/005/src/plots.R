library(ggplot2)
# --------------------
# ggplot routines
#---------------------
plots <- function(m.data) {

  
  reproscir::theme_twitter()
  p01 <- ggplot(merged.data, aes(year, ff.prod.mtoe - ff.cons.mtoe , colour=region ))+
    geom_line()+
    labs(y= "annual fossil export\nmtoe", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
    theme(legend.position = c(.2,.9), legend.title = element_blank())
  
  p02 <-ggplot(merged.data, aes(year, (ff.prod.mtoe - ff.cons.mtoe)/LP  , colour=region ))+
    geom_line()+
    labs(y= " fossil export\nmtoe per capita", x=NULL,
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
    theme(legend.position = c(.1,.9), legend.title = element_blank())
  
  
  p03 <-ggplot(merged.data, aes(year, GGXCNL*US.exchange , colour=region ))+
    geom_line()+
    labs(y= "net government revenue balance GGXCNL, 1990+\nUS$'billions", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
    theme(legend.position = c(.2,.9), legend.title = element_blank())
  
  p04 <- ggplot(merged.data, aes(year, (GGXONLB-GGXCNL)*US.exchange  , colour=region ))+
    geom_line()+
    labs(y= "interest payable/paid GGXONLB-GGXCNL, 1990+\nUS$'billions", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
    theme(legend.position = c(.2,.9), legend.title = element_blank())+
    theme(legend.position = c(.2,.9), legend.title = element_blank())
  
  
  p05 <-ggplot(merged.data, aes(year, GGXCNL.cum*US.exchange , colour=region ))+
    geom_line()+
    labs(y= "Cumulative net lending/borrowing, GGXCNL, 1990+\nUS$'billions", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
    theme(legend.position = c(.2,.9), legend.title = element_blank())
  
  
  p06 <-ggplot(merged.data, aes(year, GGXCNL.cum*US.exchange/LP, colour=region ))+
    geom_line()+
    labs(y= "Cumulative per.capita net revenue balance, GGXCNL, 1990+\nUS$'000s", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
    theme(legend.position = c(.2,.9), legend.title = element_blank())
  
  
  p07 <- ggplot(merged.data, aes(year, US.exchange , colour=region ))+
    geom_line()+
    labs(y= " local currency - US$ exchange", x=NULL,         
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/004")+
    theme(legend.position = c(.2,.9), legend.title = element_blank())
  
  
return (list(p1=p01,p2=p02,p3=p03,p4=p04,p4=p04,p5=p05,p6=p06,p7=p07 ))
}