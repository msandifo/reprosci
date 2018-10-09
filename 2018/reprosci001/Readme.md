001-Gladstone LNG
================

## Summary

Amongst the many factors that caused the doubling of Australian east
coast electricity wholesale prices in 2016, is the opening of the east
coast gas market to international exports, via the Port of Gladstone.
Time series of Gladstone Port Authority LNG export volumes, and NEM
dispatch prices from AEMO allow the correlations to be illustrated. LNG
exports are expresded in annualised tonneage. NEM market prices are in
AUD$ per megawatt hour.

## Data Sources

LNG epxorts data are sourced from the [Gladstone Port Authority (GPA)
website](http://content1.gpcl.com.au/viewcontent/CargoComparisonsSelection/CargoComparisonsSelection.aspx).

NEM electricity prices are sourced from AEMO’s half hourly price and
demand csv files.

## Code

The code base is in `r` and is best managed with in managed within
RStudio, using the `drake` package.

#### Package dependencies

If not already installed, sourcing `'./src/functions.R'` automatically
installs the package dependencies `tidyverse`, `ggplot2`, `magrittr`,
`purrr`, `stringr`, `drake`, `lubridate`, `rvest`,
`rappdirs`,`data.table`, `fasttime`, `devtools`, `wbstats` from cran,
and `hrbrthemes` from the github repo `hrbrmstr/hrbrthemes`.

#### Setup

To start we set some variables, such as the `drake.path`, read in key
functions (including the drake plan `reproplan`) and adjust the ggplot
theme.

``` r
pkgconfig::set_config("drake::strings_in_dots" = "literals")
local.path=NULL
drake.path <- dirname(rstudioapi::getSourceEditorContext()$path )
setwd(drake.path)
source('./src/packages.R')
source('./src/functions.R')
source('./src/theme.R')
source('./src/plots.R')
source('./src/plan.R')
```

#### Downloads

``` r
source('./src/downloads.R')
```

downlaods monthly AEMO csv data files into a local directory set by
`local.path` The default `local.path=NULL` uses
`rappdirs::user_cache_dir()` to set the `local.path` to a folder in the
users cache directory (for macOSX, `~/Library/cache`) to
`file.path(local.path, aemo)`. `'./src/downloads.R'` is a wrapper on the
function call
`download_aemo_aggregated`.

``` r
download_aemo_aggregated(year=2010:2018, months=1:12, local.path=local.path)
```

#### Drake plan

The code is organised and run/update via drake plan `reproplan```` (
sourced via`source(‘./src/plan.R’)\`\`\`)

``` r
drake::make( reproplan, force=T)
```

The drake `reproplan` dependency structure can be visualised

``` r
config <- drake::drake_config(reproplan)
graph <- drake::drake_graph_info(config, group = "status", clusters = "imported")
drake::render_drake_graph(graph, file="figs/rmd_render_drake.png")
```

<img src="./figs/rmd_render_drake.png" alt="hist1" align="center" style = "border: none; float: center;" width = "1000px">

Note that the drake plan `reproplan` includes

  - a directive `lng = update_gladstone( local.path=local.path)`that
    either reads the Gladstone export data from html tables as a
    data.frame and stores `lng` to disk in
    `load(file.path(validate_directory(local.path, "gladstone"),
    "lng.Rdata"))` or, if already downloaded,
    `load(file.path(validate_directory(local.path, "gladstone"),
    "lng.Rdata"))`- see code details.

  - statements to read the monthly AEMO csv files for each of the five
    NEM regions (NSW1, QLD1, SA1 TAS1, VIC1), and aggregate them as
    monthly `NEM.month` and annual `NEM.year` timeseries, as summarised
    below

<!-- end list -->

    ## # A tibble: 6 x 5
    ## # Groups:   year [1]
    ##    year month date         RRP TOTALDEMAND
    ##   <dbl> <dbl> <date>     <dbl>       <dbl>
    ## 1  2010     1 2010-01-16  75.1      23918.
    ## 2  2010     2 2010-02-14  74.8      24549.
    ## 3  2010     3 2010-03-16  25.6      23265.
    ## 4  2010     4 2010-04-15  39.0      22157.
    ## 5  2010     5 2010-05-16  29.5      23156.
    ## 6  2010     6 2010-06-15  31.7      24560.

    ## # A tibble: 6 x 4
    ##    year date         RRP TOTALDEMAND
    ##   <dbl> <date>     <dbl>       <dbl>
    ## 1  2010 2010-07-02  35.3      23330.
    ## 2  2011 2011-07-02  39.4      22925.
    ## 3  2012 2012-07-01  44.7      22314.
    ## 4  2013 2013-07-02  60.4      21753.
    ## 5  2014 2014-07-02  47.8      21501.
    ## 6  2015 2015-07-02  45.7      21746.

#### Output

``` r
source('./src/downloads.R')
```

generates three `ggplot` charts, output to `./figs` directory, with
themes prescribed in `./src/theme.R'` :

``` r
setwd("./figs")
ggsave("reprosci001.png",  readd(reprosci001.plot) ,width=8, height=5) 
ggsave("reprosci002.png",  readd(reprosci002.plot) ,width=8, height=5) 
ggsave("reprosci003.png",  readd(reprosci003.plot) ,width=8, height=5) 
```

![](Readme_files/figure-gfm/repo001-1.png)<!-- -->

![](Readme_files/figure-gfm/repo002-1.png)<!-- -->

![](Readme_files/figure-gfm/repo003-1.png)<!-- -->

## Code details

### Gladstone Port Authority (GPA)

The function call

`read_gladstone_ports<- function(year=NULL, month=NULL,fuel="Liquefied
Natural Gas", country="Total")`

scrapes data from the GPA html tables, utilising the package `rvest`,
noting that other commodities exported through the GPA, such as
`"Coal"`, can also be specified.

In our drake file, `read_gladstone_ports` is only indirectly clled via
the function `update_gladstone`

## Errata
