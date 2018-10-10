reprosci
================

## a.k.a Reproducible science

The objective is to make the code available that allows the figures at
@reprosci (<https://twitter.com/reprosci>) to be reproduced using the
raw data, as distrbuted by the relavant authorities. Some caveats may
apply, where the raw data has been prepocessed and condensed in order to
manage compute resources. All code is strictly open source. In most
cases the data processin and visualisation is achieved using `r`, and
rely on the `RStudio` envirnoment, which is strongly recommended. Some
simulations emply other codes, such as `Basilisk`.

#### Procedure

In order to dowenload the reprosci code archive use your
`terminal`

``` bash
export DOWNLOAD_PATH=~/Downloads #change path to whatever directory you want
cd $DOWNLOAD_PATH 
git clone  https://github.com/msandifo/reprosci.git
```

My repro repo’s are typcially identified by year (e.g. `2018`) and
number (e.g. `001`), sometimes with a prefix (e.f. `repro001`)

#### Example - repro `2018/reprosci001`

in `terminal`

``` bash
cd $DOWNLOAD_PATH/reprosci/2018/reprosci001  
rm -r .drake 
open reprosci001.Rproj 
```

In `rstudio console`

``` r
source("drake001.R")
```

More detailed code explanation can be found in the associated
`readme.md` in the releavnat github `master/tree`
(e.g. <https://github.com/msandifo/reprosci/tree/master/2018/reprosci001>)
