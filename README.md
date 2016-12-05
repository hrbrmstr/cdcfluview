
### :mask: cdcfluview - Retrieve U.S. Flu Season Data from the CDC FluView Portal

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/cdcfluview)](https://cran.r-project.org/package=cdcfluview) [![Travis-CI Build Status](https://travis-ci.org/NA/NA.svg?branch=master)](https://travis-ci.org/NA/NA)

**NOTE** If there's a particular data set from <https://www.cdc.gov/flu/weekly/fluviewinteractive.htm> that you want and that isn't in the package, please file it as an issue and be as specific as you can (screen shot if possible).

------------------------------------------------------------------------

The U.S. Centers for Disease Control (CDC) maintains a [portal](https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html) for accessing state, regional and national influenza statistics. The portal's Flash interface makes it difficult and time-consuming to select and retrieve influenza data. This package provides functions to access the data provided by the portal's underlying API.

The following functions are implemented:

-   `get_flu_data`: Retrieves state, regional or national influenza statistics from the CDC
-   `get_state_data`: Retrieves state/territory-level influenza statistics from the CDC
-   `get_weekly_flu_report`: Retrieves (high-level) weekly influenza surveillance report from the CDC
-   `get_mortality_surveillance_data` : (fairly self explanatory but also pretty new to the pkg and uses data from: <https://www.cdc.gov/flu/weekly/nchs.htm>

The following data sets are included:

-   `hhs_regions` HHS Region Table (a data frame with 59 rows and 4 variables)
-   `census_regions` Census Region Table (a data frame with 51 rows and 2 variables)

### News

-   See NEWS
-   Version 0.4.0 - [CRAN release](http://cran.r-project.org/web/packages/cdcfluview)
-   Version 0.4.0.999 released : another fix for the CDC API (for region parameter); added data files for HHS/Census region lookups; added weekly high-level flu report retrieval
-   Version 0.3 released : fix for the CDC API (it changed how year & region params are encoded in the request)
-   Version 0.2.1 released : bumped up `httr` version \# requirement in `DESCRIPTION` (via Issue [1](https://github.com/hrbrmstr/cdcfluview/issues/1))
-   Version 0.2 released : added state-level data retrieval
-   Version 0.1 released

### Installation

``` r
install.packages("cdcfluview")
# **OR**
devtools::install_github("hrbrmstr/cdcfluview")
```

### Usage

``` r
library(cdcfluview)
library(ggplot2)
library(dplyr)
library(statebins)

# current verison
packageVersion("cdcfluview")
#> [1] '0.5.1'

flu <- get_flu_data("hhs", sub_region=1:10, "ilinet", years=2014)
glimpse(flu)
#> Observations: 530
#> Variables: 15
#> $ REGION TYPE       <chr> "HHS Regions", "HHS Regions", "HHS Regions", "HHS Regions", "HHS Regions", "HHS Regions",...
#> $ REGION            <chr> "Region 1", "Region 2", "Region 3", "Region 4", "Region 5", "Region 6", "Region 7", "Regi...
#> $ YEAR              <int> 2014, 2014, 2014, 2014, 2014, 2014, 2014, 2014, 2014, 2014, 2014, 2014, 2014, 2014, 2014,...
#> $ WEEK              <int> 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 42, 42, 4...
#> $ % WEIGHTED ILI    <dbl> 0.830610, 1.795830, 1.162260, 0.828920, 0.744546, 1.604740, 0.697022, 0.635856, 1.793140,...
#> $ %UNWEIGHTED ILI   <dbl> 0.681009, 1.649790, 1.321020, 0.911243, 1.013950, 1.647270, 0.437619, 0.813397, 1.501530,...
#> $ AGE 0-4           <int> 101, 869, 395, 331, 358, 446, 50, 76, 310, 22, 109, 837, 403, 355, 338, 540, 57, 57, 335,...
#> $ AGE 25-49         <int> 44, 363, 455, 187, 181, 410, 43, 49, 220, 7, 37, 349, 465, 244, 182, 451, 56, 87, 225, 20...
#> $ AGE 25-64         <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N...
#> $ AGE 5-24          <int> 185, 757, 627, 530, 400, 636, 98, 154, 577, 30, 199, 676, 669, 772, 443, 741, 124, 148, 5...
#> $ AGE 50-64         <int> 13, 157, 126, 80, 80, 111, 15, 19, 110, 1, 24, 151, 130, 74, 105, 168, 18, 23, 118, 10, 2...
#> $ AGE 65            <int> 9, 107, 89, 46, 64, 77, 14, 8, 112, 1, 17, 115, 75, 64, 48, 97, 14, 12, 103, 3, 9, 114, 8...
#> $ ILITOTAL          <int> 352, 2253, 1692, 1174, 1083, 1680, 220, 306, 1329, 61, 386, 2128, 1742, 1509, 1116, 1997,...
#> $ NUM. OF PROVIDERS <int> 146, 276, 234, 299, 261, 226, 84, 119, 237, 55, 150, 265, 232, 306, 271, 235, 84, 115, 24...
#> $ TOTAL PATIENTS    <int> 51688, 136563, 128083, 128835, 106810, 101987, 50272, 37620, 88510, 11172, 51169, 131884,...

state_flu <- get_state_data(years=2015)
glimpse(state_flu)
#> Observations: 2,807
#> Variables: 8
#> $ statename            <chr> "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "...
#> $ url                  <chr> "http://adph.org/influenza/", "http://dhss.alaska.gov/dph/Epi/id/Pages/influenza/influ...
#> $ website              <chr> "Influenza Surveillance", "Influenza Surveillance Report", "Influenza & RSV Surveillan...
#> $ activity_level       <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
#> $ activity_level_label <chr> "Minimal", "Minimal", "Minimal", "Minimal", "Minimal", "Minimal", "Minimal", "Minimal"...
#> $ weekend              <chr> "Oct-10-2015", "Oct-10-2015", "Oct-10-2015", "Oct-10-2015", "Oct-10-2015", "Oct-10-201...
#> $ season               <chr> "2015-16", "2015-16", "2015-16", "2015-16", "2015-16", "2015-16", "2015-16", "2015-16"...
#> $ weeknumber           <int> 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40...

gg <- ggplot(flu, aes(x=WEEK, y=`% WEIGHTED ILI`, group=REGION))
gg <- gg + geom_line()
gg <- gg + facet_wrap(~REGION, ncol=2)
gg <- gg + theme_bw()
gg
```

<img src="README_files/README-state2015-1.png" width="576" />

``` r
msd <- get_mortality_surveillance_data()

mutate(msd$by_state, ym=as.Date(sprintf("%04d-%02d-1", Year, Week), "%Y-%U-%u")) %>% 
  select(state, wk=ym, death_pct=`Percent of Deaths Due to Pneumonia and Influenza`) %>% 
  mutate(death_pct=death_pct/100) -> df

gg <- ggplot() + geom_smooth(data=df, aes(wk, death_pct, group=state), 
                             se=FALSE, color="#2b2b2b", size=0.25) 

gb <- ggplot_build(gg)

gb$data[[1]] %>% 
  arrange(desc(x)) %>% 
  group_by(group) %>% 
  slice(1) %>% 
  ungroup() %>% 
  arrange(desc(y)) %>% 
  head(1) -> top

top_state <- sort(unique(msd$by_state$state))[top$group]

gg <- gg + geom_text(data=top, aes(as.Date(x, origin="1970-01-01"), y, label=top_state),
                     hjust=1, family="Arial Narrow", size=3, nudge_x=-5, nudge_y=-0.001)
gg <- gg + scale_x_date(expand=c(0,0))
gg <- gg + scale_y_continuous(label=scales::percent)
gg <- gg + labs(x=NULL, y=NULL,
                title="Percent of In-State Deaths Due to Pneumonia and Pnfluenza (2010-Present)")
gg <- gg + theme_bw(base_family="Arial Narrow")
gg <- gg + theme(axis.text.x=element_text(margin=margin(0,0,0,0)))
gg <- gg + theme(axis.text.y=element_text(margin=margin(0,0,0,0)))
gg <- gg + theme(axis.ticks=element_blank())
gg <- gg + theme(plot.title=element_text(face="bold", size=16))
gg
```

<img src="README_files/README-mortality-1.png" width="960" />

``` r
gg_s <- state_flu %>%
  filter(weekend=="Jan-02-2016") %>%
  select(state=statename, value=activity_level) %>%
  filter(!(state %in% c("Puerto Rico", "New York City"))) %>% # need to add PR to statebins
  mutate(value=as.numeric(gsub("Level ", "", value))) %>%
  statebins(brewer_pal="RdPu", breaks=4, 
            labels=c("Minimal", "Low", "Moderate", "High"),
            legend_position="bottom", legend_title="ILI Activity Level") +
  ggtitle("CDC State FluView (2015-01-03)")
gg_s
```

<img src="README_files/README-bins-1.png" width="672" />

### Test Results

``` r
library(cdcfluview)
library(testthat)

date()
#> [1] "Mon Dec  5 14:23:45 2016"

test_dir("tests/")
#> testthat results ========================================================================================================
#> OK: 2 SKIPPED: 0 FAILED: 0
#> 
#> DONE ===================================================================================================================
```
