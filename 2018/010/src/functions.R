`%ni%` = Negate(`%in%`) 

signif_scale <- function(x,suffix="%", sig=2, scale=100) paste0(signif(scale*x, sig), suffix)
