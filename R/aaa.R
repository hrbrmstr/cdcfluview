# CDC U.S. region names to ID map
.region_map <- c(national=3, hhs=1, census=2, state=5)

# CDC hospital surveillance surveillance area name to internal pkg use map
.surv_map <- c(`FluSurv-NET`="flusurv", `EIP`="eip", `IHSP`="ihsp")
.surv_rev_map <- c(flusurv="FluSurv-NET", eip="EIP", ihsp="IHSP")

# CDC P&I mortality GepID mapping
.geoid_map <- c(national="1", state="2", region="3")

# Our bot's user-agent string
.cdcfluview_ua <- "Mozilla/5.0 (compatible; R-cdcvluview Bot/2.0; https://github.com/hrbrmstr/cdcfluview)"

# CDC Basemap
.cdc_basemap <- "https://gis.cdc.gov/grasp/fluview/FluView1References/data/US_States_w_PR_labels.json"
