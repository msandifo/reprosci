# packages neded
  # tidyverse, lubridate, rvest, rappdirs, data.table, fasttime, purrr, hrbrthemes

  # --------------------
  # check packages
  #---------------------

  `%ni%` = Negate(`%in%`)
  cran.depend <- c('tidyverse', 'lubridate', 'rvest', 'rappdirs','data.table', 'fasttime', 'magrittr', 'devtools', 'wbstats', 'ggplot2', 'templates' )
  plic <- installed.packages()
  cran.installs <-cran.depend[cran.depend  %ni% plic]
  if (length(cran.installs >0)) install.packages(cran.installs)
  if  ('hrbrthemes' %ni% plic) devtools::install_github('hrbrmstr/hrbrthemes')
  if  ('reproscir' %ni% plic) devtools::install_github('msandifo/reproscir')