if (!exists('full.repro')) full.repro=T
library(drake)
library(magrittr)
library(stringr)
library(readxl)
library(lubridate)
library(tidyverse)
pkgconfig::set_config('drake::strings_in_dots' = 'literals')
local.path=NULL
if (!exists('drake.path')) drake.path <- dirname(rstudioapi::getSourceEditorContext()$path ) %>% stringr::str_remove('/src')
setwd(drake.path)
