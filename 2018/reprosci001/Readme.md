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

  - Gladstone LNG exports data are sourced from the [Gladstone Port
    Authority (GPA)
    website](http://content1.gpcl.com.au/viewcontent/CargoComparisonsSelection/CargoComparisonsSelection.aspx).

  - NEM electricity prices are sourced from AEMO’s half hourly price and
    demand csv files.

  - Population data is sourced from the World bank via package
    `wbstats`.

## Code

The code is in `r` and is managed within RStudio, using the `drake`
package.

The full code can be executed by open the `Rstudio` project
`reprosci001.Rproj` and sourcing

``` r
source('drake001.R')
```

Details of the steps invoked by \`\``drake001.R` are summarised below.

##### Package dependencies

``` r
source('./src/packages.R')
```

check for and, if absent, automatically install the following package
dependencies `tidyverse`, `ggplot2`, `magrittr`, `purrr`, `stringr`,
`drake`, `lubridate`, `rvest`, `rappdirs`,`data.table`, `fasttime`,
`devtools`, `wbstats` from cran, and `hrbrthemes` from the github repo
`hrbrmstr/hrbrthemes`.

##### Setup

Set variables, such as the `drake.path`, read in speciifc functions, a
ggplot theme, plot functions the drake plan `reproplan`.

``` r
source('./src/settings.R')
source('./src/packages.R')
source('./src/functions.R')
source('./src/theme.R')
source('./src/plots.R')
source('./src/plan.R')
```

##### Downloads

Check all primary data sources from relevant distribution sources and if
not already present already downloaded, retrieve new or updated
versions, into a local directory set by `local.path`.

``` r
source('./src/downloads.R')
```

The default `local.path=NULL` uses `rappdirs::user_cache_dir()` to set
the `local.path` to a folder in the users cache directory (for macOSX,
`~/Library/cache`) to `file.path(local.path, aemo)`.
`'./src/downloads.R'` is a wrapper on the function call
`download_aemo_aggregated`.

##### Drake plan

organise code and run/update via drake plan `reproplan` (loaded via
`source('./src/plan.R')`)

``` r
drake::make( reproplan, force=T)
```

with the following dependency structure

``` r
config <- drake::drake_config(reproplan)
graph <- drake::drake_graph_info(config, group = "status", clusters = "imported")
drake::render_drake_graph(graph, file="figs/rmd_render_drake.png")
```

<img src="./figs/rmd_render_drake.png" alt="hist1" align="center" style = "border: none; float: center;" width = "1000px">

<!-- Note that the drake plan ```reproplan``` includes  -->

<!-- *  a directive ```lng = update_gladstone( local.path=local.path)```that either reads the Gladstone export data from html tables as a data.frame and stores ```lng``` to disk in   ```load(file.path(validate_directory(local.path, "gladstone"), "lng.Rdata"))``` or, if already downloaded, ```load(file.path(validate_directory(local.path, "gladstone"), "lng.Rdata"))```- see code details. -->

<!-- * statements to read the monthly AEMO csv files for each of the five NEM regions (NSW1, QLD1, SA1 TAS1, VIC1), and aggregate them as monthly ```NEM.month``` and annual ```NEM.year``` timeseries, as summarised below -->

<!-- ```{r  cache=TRUE} -->

<!-- print(head(readd(NEM.month))) -->

<!-- ``` -->

<!-- ```{r  cache=TRUE} -->

<!-- print(head(readd(NEM.year))) -->

<!-- ``` -->

##### Outputs

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

#### Gladstone Port Authority (GPA)

The function call

`read_gladstone_ports<- function(year=NULL, month=NULL,fuel="Liquefied
Natural Gas", country="Total")`

scrapes data from the GPA html tables, utilising the package `rvest`,
noting that other commodities exported through the GPA, such as
`"Coal"`, can also be specified.

The drake plan indirectly calls `read_gladstone_ports` via
`update_gladstone`

#### NEM data

While the monthly NEM csv files have time stamps `SETTLEMENTDATE`
ordered `ymd hms`, the September 2016 csv files have time stamps
reversed `dmy hms`. The function `dmy_to_ymd` reorders the time stamps.

## Errata
