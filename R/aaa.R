# THIS IS NOT EXPORTED FROM MMWRweek but I need it
# Find start date for a calendar year
#
# Finds the state date given a numeric calendar year
# @author Jarad Niemi \email{niemi@@iastate.edu}
.start_date = function(year) {
  # Finds start state for this calendar year
  jan1 = as.Date(paste(year, '-01-01', sep=''))
  wday = as.numeric(MMWRweekday(jan1))
  jan1 - (wday-1) + 7*(wday>4)
}

# CDC U.S. region names to ID map
.region_map <- c(national=3, hhs=1, census=2, state=5)

# CDC hospital surveillance surveillance area name to internal pkg use map
.surv_map <- c(`FluSurv-NET`="flusurv", `EIP`="eip", `IHSP`="ihsp")
.surv_rev_map <- c(flusurv="FluSurv-NET", eip="EIP", ihsp="IHSP")

# CDC P&I mortality GepID mapping
.geoid_map <- c(national="1", state="2", region="3")

# Our bot's user-agent string
.cdcfluview_ua <- "Mozilla/5.0 (compatible; R-cdcvluview Bot/2.0; https://github.com/hrbrmstr/cdcfluview)"

# CDC Basemaps
.national_outline <- "https://gis.cdc.gov/grasp/fluview/FluView2References/Data/US_84.json"
.hhs_subregions_basemap <- "https://gis.cdc.gov/grasp/fluview/FluView2References/Data/HHSRegions_w_SubGroups.json"
.census_divisions_basemap <- "https://gis.cdc.gov/grasp/fluview/FluView2References/Data/CensusDivs_w_SubGroups.json"
.states_basemap <- "https://gis.cdc.gov/grasp/fluview/FluView2References/Data/StatesFluView.json"
.spread_basemap <- "https://gis.cdc.gov/grasp/fluview/FluView8References/Data/States_Territories_labels.json"
.surv_basemap <- "https://gis.cdc.gov/grasp/fluview/FluView1References/data/US_States_w_PR_labels.json"

# CDC Age Groups
.age_grp <- c("0-4 yr", "5-24 yr", "25-64 yr", "65+ yr")

# CDC Virus Groups
.vir_grp <- c("A (Subtyping not Performed)", "A (H1N1)pdm09", "A (Unable to Subtype)",
              "B (Lineage Unspecified)", "A (H1)", "A (H3)", "B (Victoria Lineage)",
              "B (Yamagata Lineage)", "H3N2v")

# Week Starts

.tmp <- lapply(1962:2030, .start_date)

mapply(function(.x, .y) {
  data_frame(
    wk_start = seq(.tmp[[.x]], .tmp[[.y]], "1 week"),
    wk_num = 1:length(wk_start)
  ) -> tmp
  tmp[-nrow(tmp),]
}, 1:(length(.tmp)-1), 2:length(.tmp), SIMPLIFY=FALSE) -> .wk

.wk <- Reduce(rbind.data.frame, .wk)
.wk$mmwrid <- 1:nrow(.wk)