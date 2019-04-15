utils::globalVariables(c(".", "mmwrid", "season", "seasonid", "week_start", "wk_start", "wk_end", "year_wk_num"))

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

# Global HTTR timeout
.httr_timeout <- 120
