001-Gladstone LNG
================

## Summary

time series of monthly Gladstone Port Authority LNG export volumes, and
averaed NEM market dispatch prices. LNG exprts are in annualised
tonneage. NEM market prices are in AUD$ per megawatt hour.

## Data Sources

  - Gladstone Port authority -
    <http://content1.gpcl.com.au/viewcontent/CargoComparisonsSelection/CargoComparisonsSelection.aspx>,

  - AEMO dispatch files by region id

## Code

The code is organised and run/update via a drake plan.
<!--html_preserve-->

<div id="htmlwidget-ec897849c5c50a6f7846" class="visNetwork html-widget" style="width:672px;height:480px;">

</div>

<script type="application/json" data-for="htmlwidget-ec897849c5c50a6f7846">{"x":{"nodes":{"id":["\"-\"","\"-15\"","\"/data/gas_generation.csv\"","\"gas_\"","\"NSW\"","\"QLD\"","\"SA\"","\"TAS\"","\"VIC\"","aemo","gas.tidy","gas.use","lng","NEM.month","NEM.year","NSW1","QLD1","reprosci001.plot","reprosci002.plot","reprosci003.plot","SA1","TAS1","VIC1","status: imported"],"deps":[null,null,null,null,null,null,null,null,null,{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}],"trigger":[null,null,null,null,null,null,null,null,null,{},{},{},{},{},{},{},{},{},{},{},{},{},{},null],"label":["\"-\"\n0.003s","\"-15\"\n0.003s","\"/data/gas_generation.csv\"\n0.003s","\"gas_\"\n0.003s","\"NSW\"\n0.003s","\"QLD\"\n0.003s","\"SA\"\n0.002s","\"TAS\"\n0.003s","\"VIC\"\n0.002s","aemo\n2.247s","gas.tidy\n0.023s","gas.use\n0.013s","lng\n0.013s","NEM.month\n0.111s","NEM.year\n0.073s","NSW1\n1.072s","QLD1\n1.193s","reprosci001.plot\n1.911s","reprosci002.plot\n0.123s","reprosci003.plot\n0.142s","SA1\n1.165s","TAS1\n1.134s","VIC1\n1.085s","status: imported"],"command":[null,null,null,null,null,null,null,null,null,"data.table::rbindlist(list(NSW1, QLD1, SA1, TAS1, VIC1))","tidyr::gather(gas.use[, 1:5], gas.type, value, -year, -month) %>% \n    dplyr::mutate(date = lubridate::ymd(paste0(year, '-', month, \n        '-15')), mdays = lubridate::days_in_month(date), mw = value * \n        1000/(mdays * 24) * 12, gas.type = stringr::str_remove_all(gas.type, \n        'gas_'))","gas.use <- data.table::fread(paste0(drake.path, '/data/gas_generation.csv')) %>% \n    purrr::set_names(~stringr::str_to_lower(.)) %>% dplyr::mutate(date = lubridate::ymd(paste0(year, \n    '-', month, '-15')), sum = gas_ccgt + gas_ocgt + gas_steam, \n    efficiencyLower = (gas_ccgt * 0.45 + gas_ocgt * 0.3 + gas_steam * \n        0.3)/sum, efficiencyUpper = (gas_ccgt * 0.5 + gas_ocgt * \n        0.35 + gas_steam * 0.35)/sum)","update_gladstone(local.path = local.path)","aemo %>% dplyr::group_by(year, month) %>% dplyr::summarise(date = mean(SETTLEMENTDATE) %>% \n    as.Date(), RRP = sum(RRP * TOTALDEMAND)/sum(TOTALDEMAND), \n    TOTALDEMAND = 5 * sum(TOTALDEMAND)/length(TOTALDEMAND))","aemo %>% dplyr::group_by(year) %>% dplyr::summarise(date = mean(SETTLEMENTDATE) %>% \n    as.Date(), RRP = sum(RRP * TOTALDEMAND)/sum(TOTALDEMAND), \n    TOTALDEMAND = 5 * sum(TOTALDEMAND)/length(TOTALDEMAND))","get_aemo_data(state = 'NSW')","get_aemo_data(state = 'QLD')","reprosci001(lng, NEM.month, NEM.year)","reprosci002(gas.use, gas.tidy, NEM.month)","reprosci003(gas.use, gas.tidy)","get_aemo_data(state = 'SA')","get_aemo_data(state = 'TAS')","get_aemo_data(state = 'VIC')",null],"status":["missing","missing","missing","missing","missing","missing","missing","missing","missing","outdated","outdated","outdated","outdated","outdated","outdated","outdated","outdated","outdated","outdated","outdated","outdated","outdated","outdated","imported"],"type":["file","file","file","file","file","file","file","file","file","object","object","object","object","object","object","object","object","object","object","object","object","object","object","cluster"],"font.size":[20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20],"color":["#9A32CD","#9A32CD","#9A32CD","#9A32CD","#9A32CD","#9A32CD","#9A32CD","#9A32CD","#9A32CD","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000","#1874CD"],"shape":["square","square","square","square","square","square","square","square","square","dot","dot","dot","dot","dot","dot","dot","dot","dot","dot","dot","dot","dot","dot","diamond"],"level":[1,1,1,1,1,1,1,1,1,5,3,2,5,6,6,4,4,7,7,4,4,4,4,4],"title":["\"-\"","\"-15\"","\"/data/gas_generation.csv\"","\"gas_\"","\"NSW\"","\"QLD\"","\"SA\"","\"TAS\"","\"VIC\"","data.table::rbindlist(list(NSW1,&nbsp;QLD1,&nbsp;SA1,&nbsp;TA...","tidyr::gather(gas.use[,&nbsp;1:5],&nbsp;gas.type,&nbsp;value,...","gas.use&nbsp;<-&nbsp;data.table::fread(paste0(drake.path...","update_gladstone(local.path&nbsp;=&nbsp;local.path)","aemo&nbsp;%>%&nbsp;dplyr::group_by(year,&nbsp;month)&nbsp;%>%&nbsp;dply...","aemo&nbsp;%>%&nbsp;dplyr::group_by(year)&nbsp;%>%&nbsp;dplyr::summ...","get_aemo_data(state&nbsp;=&nbsp;'NSW')","get_aemo_data(state&nbsp;=&nbsp;'QLD')","reprosci001(lng,&nbsp;NEM.month,&nbsp;NEM.year)","reprosci002(gas.use,&nbsp;gas.tidy,&nbsp;NEM.month)","reprosci003(gas.use,&nbsp;gas.tidy)","get_aemo_data(state&nbsp;=&nbsp;'SA')","get_aemo_data(state&nbsp;=&nbsp;'TAS')","get_aemo_data(state&nbsp;=&nbsp;'VIC')","data.table::fread, data.table::rbindlist, dply..."],"x":[-0.75,-0.875,-0.25,-1,0.75,0.875,1,-0.125,0.625,0.5,-0.25,0.0625,-0.0625,-0.6875,0,0.5625,0.6875,-0.3125,-0.9375,0.4375,0.8125,0.1875,0.4375,0.3125],"y":[-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,-0.5,-0.5,0.5,0.5,-0.5,-0.5,1,1,0.5,-0.5,-0.5,-0.5,-1]},"edges":{"from":["status: imported","status: imported","status: imported","status: imported","\"NSW\"","status: imported","status: imported","status: imported","status: imported","status: imported","\"VIC\"","\"SA\"","\"QLD\"","\"TAS\"","NSW1","QLD1","SA1","TAS1","VIC1","\"-\"","\"-\"","\"-15\"","\"-15\"","\"/data/gas_generation.csv\"","\"gas_\"","gas.use","gas.use","gas.use","aemo","aemo","status: imported","status: imported","lng","NEM.month","NEM.month","NEM.year","status: imported","gas.tidy","gas.tidy","status: imported","status: imported"],"to":["gas.use","gas.tidy","aemo","lng","NSW1","NSW1","QLD1","SA1","TAS1","VIC1","VIC1","SA1","QLD1","TAS1","aemo","aemo","aemo","aemo","aemo","gas.use","gas.tidy","gas.use","gas.tidy","gas.use","gas.tidy","gas.tidy","reprosci002.plot","reprosci003.plot","NEM.month","NEM.year","NEM.month","NEM.year","reprosci001.plot","reprosci001.plot","reprosci002.plot","reprosci001.plot","reprosci001.plot","reprosci002.plot","reprosci003.plot","reprosci002.plot","reprosci003.plot"],"file":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],"arrows":["to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to"],"smooth":[true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"layout":{"hierarchical":{"enabled":true,"direction":"LR"}},"edges":{"smooth":false},"physics":{"stabilization":false},"interaction":{"navigationButtons":true}},"groups":null,"width":null,"height":null,"idselection":{"enabled":false,"style":"width: 150px; height: 26px","useLabels":true,"main":"Select by id"},"byselection":{"enabled":false,"style":"width: 150px; height: 26px","multiple":false,"hideColor":"rgba(200,200,200,0.5)"},"main":{"text":"Dependency graph","style":"font-family:Georgia, Times New Roman, Times, serif;font-weight:bold;font-size:20px;text-align:center;"},"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","highlight":{"enabled":false,"hoverNearest":false,"degree":1,"algorithm":"all","hideColor":"rgba(200,200,200,0.5)","labelOnly":true},"collapse":{"enabled":true,"fit":false,"resetHighlight":true,"clusterOptions":null},"legend":{"width":0.2,"useGroups":false,"position":"left","ncol":1,"stepX":100,"stepY":100,"zoom":true,"nodes":{"label":["Outdated","Imported","Missing","Object","File","Cluster"],"color":["#000000","#1874CD","#9A32CD","#888888","#888888","#888888"],"shape":["dot","dot","dot","dot","square","diamond"],"font.color":["black","black","black","black","black","black"],"font.size":[20,20,20,20,20,20],"id":[2,5,6,7,9,10]},"nodesToDataframe":true},"igraphlayout":{"type":"square"},"tooltipStay":300,"tooltipStyle":"position: fixed;visibility:hidden;padding: 5px;white-space: nowrap;font-family: verdana;font-size:14px;font-color:#000000;background-color: #f5f4ed;-moz-border-radius: 3px;-webkit-border-radius: 3px;border-radius: 3px;border: 1px solid #808074;box-shadow: 3px 3px 10px rgba(0, 0, 0, 0.2);"},"evals":[],"jsHooks":[]}</script>

<!--/html_preserve-->

AEMO data files are dowloaded to a local directory set by *local.path*
By dafult local.path is set to NULL,a nd data is downloaded via
rappdirs::\_\_ to the users cache direcrtory (MACOSX, \~/Library/cache)
wheer it sis troerd in fodlers aemo. The date fiels are read into
timeseires for each Region, abd then agreated acorss the NEM as monthly
and annual series.

Gladssone exports are read form html tables (via rvest) and stored in

## Output

The code generates three charts :

![](Readme_files/figure-gfm/repo001-1.png)<!-- -->

![](Readme_files/figure-gfm/repo002-1.png)<!-- -->

![](Readme_files/figure-gfm/repo003-1.png)<!-- -->

## Code details

We sue rvest to download the data from ladstine prot authority

``` r
 read_gladstone_ports<- function(year=NULL, 
                                 month=NULL,
                                 fuel="Liquefied Natural Gas",
                                 country="Total"){
  args <- as.list(match.call())
   if (is.null(year)) year <- lubridate::year(Sys.Date())
  if (is.null(month)) {
    current.month <- lubridate::month(Sys.Date())
    #current month not posted (usually not posted until second week of current month)
 
    if (current.month>1 ) month <- current.month <- 1  else if (is.null(args$year)) {
      month=12
      year<-year-1
      }
  }
   if (month>= 10) yearmonth= paste(year,month, sep="") else 
     yearmonth= paste(year,month, sep="0")
   message(paste(fuel, month, year))
   url<-paste0("http://content1.gpcl.com.au/viewcontent/CargoComparisonsSelection/CargoOriginDestination.aspx?View=C&Durat=M&Key=",yearmonth)
   wg <- rvest::html_session(url )
   batches <- rvest::read_html(wg) %>%
     rvest::html_nodes("#MainContent_pnlResults")   #class(batches)
   table <- batches %>%
     rvest::html_nodes("td") %>%
     rvest::html_text()
   lng.ind <- which( table==fuel)
   t.ind <-which(str_detect(table,country))
   t.lng.ind  <- t.ind[t.ind>lng.ind][1]
   value <- table[t.lng.ind+1] %>% str_replace_all(",","") %>%as.numeric()
   mdays <- lubridate::days_in_month(lubridate::ymd(paste(year,month, "01", sep="-")))
   if(country=="Total"){
     ships <- table[t.lng.ind+2] %>% str_replace_all(",","") %>%as.numeric()
     return(data.frame(year=year, 
                       month=month, 
                       date=lubridate::ymd(paste(year,month, "15", sep="-")),
                       tonnes=value, 
                       shipments=ships, 
                       mdays=mdays))
   } else 
     return(data.frame(year=year, 
                       month=month,  
                       date=lubridate::ymd(paste(year,month, "15", sep="-")),
                       tonnes=value,
                       mdays=mdays))
 }
```

## Errata
