002
================

## Gladstone LNG

Amongst the many factors that caused Australian east coast electricity
wholesale prices to double ind 2016 was the opening of the east coast
gas market to internatinal LNG exports, via the Port of Gladstone. Here
I explore atime series of Gladstone Port Authority LNG export volumes,
and QLD NEM market demand to illustrate the correlations. LNG exports
are expresed in annualised tonneage. NEM demand in megawatts.

## Data Sources

LNG epxorts data are sourced from the [Gladstone Port Authority (GPA)
website](http://content1.gpcl.com.au/viewcontent/CargoComparisonsSelection/CargoComparisonsSelection.aspx).

NEM demand are sourced from AEMO’s half hourly price and demand csv
files.

## Code

The code base is in `r` and is best managed with in managed within
RStudio, using the `drake` package.

#### Package dependencies

If not already installed, sourcing `'./src/functions.R'` automatically
installs the package dependencies `tidyverse`, `ggplot2`, `magrittr`,
`purrr`, `stringr`, `drake`, `lubridate`, `rvest`,
`rappdirs`,`data.table`, `fasttime`, `devtools`, `wbstats` , `zoo` from
cran, and `hrbrthemes` from the github repo `hrbrmstr/hrbrthemes`.

#### Setup

To start we set some variables, such as the `drake.path`, read in key
functions (including the drake plan `reproplan`) and adjust the ggplot
theme.

``` r
source('./src/settings.R')
source('./src/theme.R')
source('./src/functions.R')
source('./src/plan.R')
source('./src/plots.R')
```

#### Downloads

``` r
source('./src/downloads.R')
```

directs the downlaod of the AEMO csv data files to be downloaded into
the local directory set by `local.path` By default `local.path=NULL` in
which case data is downloaded via `rappdirs::user_cache_dir()` to a
folder in the users cache directory (for macOSX, `~/Library/cache`) to
`file.path(local.path, aemo)`. `'./src/downloads.R'` is a wrapper on the
function
calls

``` r
download_aemo_aggregated(year=2010:2018, months=1:12, local.path=local.path)
download_aemo_current( local.path=local.path )
```

#### Drake plan

The code is organised and run/update via drake plan `reproplan` (
sourced via `source('./src/plan.R')`)

``` r
drake::make( reproplan, force=T)
```

The `reproplan` dependency structure can be easily visualised

``` r
config <- drake::drake_config(reproplan)
graph <- drake::drake_graph_info(config, group = "status", clusters = "imported")
drake::render_drake_graph(graph, file="figs/rmd_render_drake.png")
```

<img src="./figs/rmd_render_drake.png" alt="hist1" align="center" style = "border: none; float: center;" width = "1000px">

Note that `reproplan` includes

  - the directive `lng = update_gladstone( local.path=local.path)` which
    either reads the Gladstone export data from the relevant GPA html
    tables as a data.frame and stores `lng` to disk in
    `load(file.path(validate_directory(local.path, "gladstone"),
    "lng.Rdata"))` or, if already downloaded,
    `load(file.path(validate_directory(local.path, "gladstone"),
    "lng.Rdata"))`- see code details.

  - statements to read the monthly AEMO csv files for each of the NEM
    region QLD1, and aggregate them as monthly `QLD.month` timeseries.

<!-- end list -->

    ## # A tibble: 6 x 5
    ## # Groups:   year [1]
    ##    year month date         RRP TOTALDEMAND
    ##   <dbl> <dbl> <date>     <dbl>       <dbl>
    ## 1  2007     1 2007-01-16  86.0       6281.
    ## 2  2007     2 2007-02-14  39.9       6143.
    ## 3  2007     3 2007-03-16  51.2       6322.
    ## 4  2007     4 2007-04-15  78.8       5708.
    ## 5  2007     5 2007-05-16  63.0       5731.
    ## 6  2007     6 2007-06-15 218.        5830.

#### Output

Output charts using `ggplot` are saved to the `./figs` directory :

``` r
p002<-drake::readd(p002)
ggsave("./figs/p002_01.png",  p002$p1, width=8, height=5) 
```

## Code details

### Gladstone Port Authority (GPA)

The function call

`read_gladstone_ports(year=NULL, month=NULL,fuel="Liquefied Natural
Gas", country="Total")`

scrapes data from the GPA html tables, utilising the package `rvest`,
noting that other commodities exported through the GPA, such as
`"Coal"`, can also be specified. TThe function call

read\_gladstone\_ports\<- function(year=NULL, month=NULL,fuel=“Liquefied
Natural Gas”, country=“Total”)

scrapes data from the GPA html tables, utilising the package rvest,
noting that other commodities exported through the GPA, such as “Coal”,
can also be specified.

The drake plan indirectly calls `read_gladstone_ports` via
`update_gladstone`

#### NEM data

While the monthly NEM csv files have time stamps `SETTLEMENTDATE`
ordered `ymd hms`, the September 2016 csv files have time stamps
reversed `dmy hms`. The function `dmy_to_ymd` reorders the time stamps
to \`\`ymd hms\`\`\`.

NEM data

While the monthly NEM csv files have time stamps SETTLEMENTDATE ordered
ymd hms, the September 2016 csv files have time stamps reversed dmy hms.
The function dmy\_to\_ymd reorders the time stamps.

## Errata
