`%ni%` = Negate(`%in%`) 

lag_x <- function(my.lag =0,  df=cg.ch4.spread,r=T){
  names(df) <-c("date", "data1", "data2","grouping")
  print(names(df))
  if (my.lag>0) df$data2<- dplyr::lag(df$data2, abs(my.lag))  
  if (my.lag<0)  df$data2 <- dplyr::lead(df$data2, abs(my.lag)) 
  models <- df %>%
    split(.$grouping) %>%
    map(~lm(.$data1 ~ .$data2, data=. ))
  
  if (r==T) { my.return <- models %>% map(summary) %>%  map_dbl(~.$r.squared)  } else {
    my.return <-  models %>%  map(summary) }
  return(my.return)
}


lag_x_i <- function(my.lags, df=cg.ch4.spread, gather=T){
  lagged.df <-   map(my.lags,df=df, lag_x, r=T) %>% 
    reduce(rbind) %>% 
    as.data.frame()  %>%
    mutate(lag=my.lags)
  if (gather) return(gather(lagged.df, period, `r-squared`,-lag)) else 
    return(lagged.df)
}


add_cpt_groups<-function(this.df, groups, col="date"){
  groups<- groups[order(groups)]
  my.col<- which(names(this.df)==col)
  my.vec<- this.df[ ,my.col ]
  this.df$group <- 1
  for (i in 2:(length(groups)+1))
    this.df$group[my.vec > groups[i-1]] <- i
  this.df$group<- factor(this.df$group)
  this.df
}

signif_scale <- function(x,suffix="%", sig=2, scale=100) paste0(signif(scale*x, sig), suffix)

