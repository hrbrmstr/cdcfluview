
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/cdcfluview)](https://cran.r-project.org/package=cdcfluview)
[![Travis-CI Build
Status](https://travis-ci.org/hrbrmstr/cdcfluview.svg?branch=master)](https://travis-ci.org/hrbrmstr/cdcfluview)
[![Coverage
Status](https://img.shields.io/codecov/c/github/hrbrmstr/cdcfluview/master.svg)](https://codecov.io/github/hrbrmstr/cdcfluview?branch=master)

I M P O R T A N T
=================

The CDC migrated to a new non-Flash portal and back-end APIs changed.
This is a complete reimagining of the package and — as such — all your
code is going to break. Please use GitHub issues to identify previous
API functionality you would like ported over. There’s a [release
candidate for
0.5.2](https://github.com/hrbrmstr/cdcfluview/releases/tag/v0.5.2) which
uses the old API but it likely to break in the near future given the
changes to the hidden API. You can do what with
`devtools::install_github("hrbrmstr/cdcfluview", ref="58c172b")`.

All folks providing feedback, code or suggestions will be added to the
DESCRIPTION file. Please include how you would prefer to be cited in any
issues you file.

If there’s a particular data set from
<https://www.cdc.gov/flu/weekly/fluviewinteractive.htm> that you want
and that isn’t in the package, please file it as an issue and be as
specific as you can (screen shot if possible).

:mask: cdcfluview
=================

Retrieve U.S. Flu Season Data from the CDC FluView Portal

Description
-----------

The U.S. Centers for Disease Control (CDC) maintains a portal
<http://gis.cdc.gov/grasp/fluview/fluportaldashboard.html> for accessing
state, regional and national influenza statistics as well as Mortality
Surveillance Data. The Flash interface makes it difficult and
time-consuming to select and retrieve influenza data. This package
provides functions to access the data provided by the portal’s
underlying API.

What’s Inside The Tin
---------------------

The following functions are implemented:

-   `agd_ipt`: Age Group Distribution of Influenza Positive Tests
    Reported by Public Health Laboratories
-   `cdcfluview`: Tools to Work with the ‘CDC’ ‘FluView’ ‘API’
-   `cdc_coverage_map`: Retrieve CDC U.S. Coverage Map
-   `geographic_spread`: State and Territorial Epidemiologists Reports
    of Geographic Spread of Influenza
-   `hospitalizations`: Laboratory-Confirmed Influenza Hospitalizations
-   `ilinet`: Retrieve ILINet Surveillance Data
-   `ili_weekly_activity_indicators`: Retrieve weekly state-level ILI
    indicators per-state for a given season
-   `pi_mortality`: Pneumonia and Influenza Mortality Surveillance
-   `state_data_providers`: Retrieve metadat about U.S. State CDC
    Provider Data
-   `surveillance_areas`: Retrieve a list of valid sub-regions for each
    surveillance area.
-   `who_nrevss`: Retrieve WHO/NREVSS Surveillance Data

The following data sets are included:

-   `hhs_regions` HHS Region Table (a data frame with 59 rows and 4
    variables)
-   `census_regions` Census Region Table (a data frame with 51 rows and
    2 variables)

Installation
------------

``` r
devtools::install_github("hrbrmstr/cdcfluview")
```

Usage
-----

``` r
library(cdcfluview)

# current verison
packageVersion("cdcfluview")
```

    ## [1] '0.7.0'

### EXAMPLES COMING SOON

Code of Conduct
---------------

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
