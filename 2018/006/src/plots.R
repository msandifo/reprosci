library(ggplot2)
# --------------------
# ggplot routines
#---------------------
plots <- function(cons.ton.world,  all.black=T) {

  cg.n<-reproscir::cagr(cons.ton.world)
  cg.10<-reproscir::cagr(tail(cons.ton.world,10))
  cons.ton.world.proj<- reproscir::project_cagr(cons.ton.world , n=82)
  cons.ton.world.proj.10<- reproscir::project_cagr(tail(cons.ton.world,10) , n=82)
  tw2h=1/63
  all.balck=
  if(!all.black)colours<- c("black","darkgreen", "red3", "blue2") else
  colours<- rep("black",4)
  
  reproscir::theme_twitter()
  p01 <-  ggplot(data=cons.ton.world)+
    geom_hline(yintercept = 44 *tw2h , size=.3)+
    geom_hline(yintercept = 63 *tw2h, colour=colours[3], size=.3)+
    #   geom_hline(yintercept = 63*c(.25,.5,.75)*tw2h , position="jitter",colour="Red3", linetype=2, size=.13)+
    geom_hline(yintercept=18*tw2h,   colour=colours[2], size=.3)+
    geom_line(data=cons.ton.world.proj %>% head(51),aes(x=year, y=value),
              position="jitter", colour="white", size=2.25)+
    geom_line(data=cons.ton.world.proj %>% head(51),aes(x=year, y=value),
              position="jitter", colour=colours[4], size=.95)+
    geom_line(data=cons.ton.world.proj.10,aes(x=year, y=value),
              position="jitter",  colour="white", size=2.25)+
    geom_line(data=cons.ton.world.proj.10,aes(x=year, y=value),
              position="jitter", colour=colours[4], size=.95)+
    geom_line(aes(x=year, y=value),col=colours[2], size=1.7, alpha=1)+
    #  geom_vline(xintercept=2053 , position="jitter", colour="DarkGreen", linetype=2, size=.3)+
    #  geom_vline(xintercept=2075, position="jitter", colour="DarkGreen", linetype=2, size=.3)+
    scale_y_continuous(sec.axis = sec_axis(~.*63, "terawatts" ) )+
    theme(axis.text.y.left = element_text(color = colours[2]),
          axis.title.y.left= element_text(  color =  colours[2]),
          axis.title.y.right= element_text(angle = -90, hjust = 0, color = colours[1]))+
    
    labs(y='hiros',
         x=NULL,
         #  title = "the hiro graph" ,
         subtitle="the hiro graph\nglobal primary energy consumption",
         caption= "Mike Sandiford, msandifo@gmail.com\n repo: https://github.com/msandifo/reprosci -> 2018/006")+#+theme_xkcd()
    annotate("text", x=2075,y=44*tw2h, label='2075',
             hjust=-.1, vjust=1.2, size=3)+
    annotate("text", x=2053,y=44*tw2h, label='2053',
             hjust=-.1, vjust=1.2, size=3)+
    annotate("text", x=2068,y=63*tw2h, label='2068',
             colour=colours[3] , hjust=-.1, vjust=1.2, size=3)+
    annotate("text", x=2098,y=63*tw2h, label='2098',
             colour=colours[3], hjust=-.1, vjust=1.2, size=3)+
    annotate("text", x=1990,y=20*tw2h, label='human energy consumption',
             colour=colours[2] )+
    annotate("text", x=1990,y=65*tw2h, label='one hiro',
             colour=colours[3])+
    annotate("text", x=1990,y=46*tw2h, label='plate tectonics' ) +
    
    annotate("text", x=2038,y=55*tw2h,hjust=0,
             label='               assuming\n          growth rate \nof last 50 years       ',
             col=colours[4], size=3)+
    annotate("text", x=2062,y=32*tw2h,
             label='                assuming\n       growth rate\nof last 10 years',
             col=colours[4], size=3)+
    annotate("text", x=1990,y=60*tw2h,
             label='energy equivalent of 31 million\n"little boy" bomb blasts per year',
             col=colours[2], size=3)+
    annotate("text", x=1990,y=42*tw2h,
             label="all the Earth's earthquakes, volcanoes ...", size=3)+
    annotate("text", x=1990,y=16*tw2h,
             label="all the lights, cars, comms ...", size=3, col=colours[2])+
    annotate("text", x=2068, y=66*tw2h, label=paste0(signif(cg.n,2),'% p.a.'),colour=colours[4] , size=3)+
    annotate("text", x=2099,y=66*tw2h, label=paste0(signif(cg.10,2),'% p.a.'),colour=colours[4] , size=3)

  
return (list(p1=p01  ))
}