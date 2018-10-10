@reprosci
================

## a.k.a Reproducible science

The objective is to make the code available that allows the figures at
@reprosci (<https://twitter.com/reprosci>) to be reproduced using raw
data as distrbuted by the relavant authorities. Some caveats may apply,
where the raw data has been prepocessed and condensed in order to manage
compute resources. All code is strictly open source. In most cases, data
processing and visualisation is achieved using `r`, and relies on the
`RStudio` environment, which is strongly recommended. Some simulations
employ other codes, such as `Basilisk`.

#### Procedure

The easist way to download the `reprosci` github repo is to use the
`terminal`. The Following applies for the `bash`
shell.

``` bash
export DOWNLOAD_PATH=~/Downloads #change path to whatever directory you want
cd $DOWNLOAD_PATH 
git clone  https://github.com/msandifo/reprosci.git
```

My `repro` repo’s are typcially identified by a year (e.g. `2018`) and a
sequential numeric string starting `001`, sometimes with a prefix (e.g.
`repro001`)

#### Example - repro `2018/reprosci001`

In `terminal`

``` bash
cd $DOWNLOAD_PATH/reprosci/2018/reprosci001  
rm -r .drake 
open reprosci001.Rproj 
```

In `RStudio console`

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

The default `full.repro=FALSE` checks existing downloads, and performs
an incremental update downloading any new files on remote servers and,
if needed, appending any data structures storred in `./data` such as
`./data/data.Rdata`.

More detailed code explanation can be found in the associated
`readme.md` in the relevant github `master/tree` directory
(e.g. <https://github.com/msandifo/reprosci/tree/master/2018/reprosci001>)
