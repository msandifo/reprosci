@reprosci
================

## a.k.a Reproducible science

#### The `repro` principle

`if (!reproducible_by(others)) FALSE else TRUE`

More specifically, my objective is to make instructions available that
allow the figures at @reprosci (<https://twitter.com/reprosci>) to be
reproduced, or `repro`’d using the primary (or raw) open source data as
distributed by the relavant authorities.

More personally, my hope is to cure a life-long addiction to `impetus`
code.

Some caveats apply, for example, where the raw data needs prepocessing
in order to manage compute resources.

All code used is strictly open source. My primary `repro` data
processing and visualisation language is `r`, and I rely heavily on the
extraordinary powers of the `RStudio` environment for development and
implementation.

Howvever, the `repro` principal applies to any codes, data analysis and
simulations. For example some of my `repro`’s will provide tsunami
simulations employing`Basilisk`.

#### Procedure

A straightforward way to download the `reprosci` github `repo` is to use
the `terminal`, as per the following `bash` shell
commands.

``` bash
export DOWNLOAD_PATH=~/Downloads #change path to whatever directory you want
cd $DOWNLOAD_PATH 
git clone  https://github.com/msandifo/reprosci.git
```

My `repro` `repo`’s are typcially identified by a year (e.g. `2018`) and
a sequential numeric string starting `001`, sometimes with a prefix
(e.g. `repro001`)

#### Example - repro `2018/reprosci001`

In `terminal`

``` bash
cd $DOWNLOAD_PATH/reprosci/2018/reprosci001  
rm -r .drake 
open reprosci001.Rproj 
```

In RStudio’s `console`

``` r
source("drake.R")
```

A full `repro` can be achieved by setting the `full.repro=TRUE` prior to
`source("drake.R")`. This ensures downloads of relevant datasets and
full processing, as per `./src/downloads.R`

``` r
full.repro=TRUE
source("drake.R")
```

The default `full.repro=FALSE` in `drake.R` typically checks existing
downloads, and performs an incremental update downloading any new files
on remote servers and, if needed, appending relevant data structures in
`./data`, such as `./data/data.Rdata`.

More detailed code explanation can be found in the associated
`readme.md` in the relevant `repro` github `master/tree` directory
(e.g. <https://github.com/msandifo/reprosci/tree/master/2018/reprosci001>)
