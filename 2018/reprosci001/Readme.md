001-Gladstone LNG
================

## Summary

Amongst the many factors that caused Australian east coast electricity
wholesale prices to double between 2015 and 2016, is the opening of the
east coast gas market to internatinal exports. Here I explore time
series of Gladstone Port Authority LNG export volumes, and NEM market
dispatch prices to illustrate the correlations. LNG exports are expresed
in annualised tonneage. NEM market prices are in AUD$ per megawatt hour.

## Package dependencies

## Data Sources

LNG epxorts data are sourced from the [Gladstone Port Authority
website](http://content1.gpcl.com.au/viewcontent/CargoComparisonsSelection/CargoComparisonsSelection.aspx).

NEM electricity prices are sourced from AEMO’s half hourly rpice and
demand files.

## Code

The code base uses the drake package.

To start we set some variables, such as the `drake.path`, read in key
functions (including the drake plan `reproplan001`) an set a ggplot
theme.

``` r
pkgconfig::set_config("drake::strings_in_dots" = "literals")
local.path=NULL
drake.path <- dirname(rstudioapi::getSourceEditorContext()$path )
setwd(drake.path)
source('./src/functions001.R')
source('./src/themes001.R')
```

AEMO data files are downloaded to a local directory set by `local.path`
By dafult `local.path=NULL` in which case data is downloaded via
`rappdirs::user_cache_dir()` to a folder in the users cache directory
(for macOSX, `~/Library/cache`) to `file.path(local.path,
aemo)`.

``` r
download_aemo_aggregated(year=2010:2018, months=1:12, local.path=local.path)
download_aemo_current( local.path=local.path )
```

With the data he code is organised and run/update via drake

``` r
drake::make( reproplan001, force=T)
```

The drake plan `reproplan001` dependency structure can be easily
visualised

``` r
config <- drake::drake_config(reproplan001)
graph <- drake::drake_graph_info(config, group = "status", clusters = "imported")
drake::render_drake_graph(graph, file="figs/rmd_render_drake.png")
```

<img src="./figs/rmd_render_drake.png" alt="hist1" align="center" style = "border: none; float: center;" width = "1000px">

Note that the drake plan includes

  - the statement `lng = update_gladstone( local.path=local.path)` which
    either reads the Gladstone export data from html tables as a
    data.frame and stores `lng` to disk in `file.path(local.path, "lng",
    "lng.Rdata")`, or if already dowlnoaded `load(file.path(local.path,
    "lng", "lng.Rdata"))`- see code details.
  - statements to read the monthly AEMO data files for each of the five
    region, and aggregated them as monthly `NEM.month` and annual
    `NEM.year` timeseries.

## Output

The code generates three charts, output to `./figs` directory :

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
