#' Retrieve weekly state-level ILI indicators per-state for a given season
#'
#' @md
#' @param season_start_year numeric; start year for flu season (e.g. 2017 for 2017-2018 season)
#' @references
#' - [ILI Activity Indicator Map Portal](https://gis.cdc.gov/grasp/fluview/main.html)
#' @note These statistics use the proportion of outpatient visits to healthcare providers
#' for influenza-like illness to measure the ILI activity level within a state. They do
#' not, however, measure the extent of geographic spread of flu within a state. Therefore,
#'  outbreaks occurring in a single city could cause the state to display high activity levels.\cr
#' \cr
#' Data collected in ILINet may disproportionately represent certain populations within
#' a state, and therefore may not accurately depict the full picture of influenza activity
#' for the whole state.\cr
#' \cr
#' All summary statistics are based on either data collected in ILINet, or reports from
#' state and territorial epidemiologists. Differences in the summary data presented by
#' CDC and state health departments likely represent differing levels of data completeness
#' with data presented by the state likely being the more complete.
#' @export
#' @examples \dontrun{
#' ili_weekly_activity_indicators(2016)
#' }
ili_weekly_activity_indicators <- function(season_start_year) {

  jsonlite::fromJSON("https://gis.cdc.gov/grasp/fluView1/Phase1IniP") %>%
    jsonlite::fromJSON() -> meta

  season <- season_start_year - 1960

  res <- httr::GET(sprintf("https://gis.cdc.gov/grasp/fluView1/Phase1SeasonDataP/%s",
                           season))

  httr::stop_for_status(res)

  res <- httr::content(res, as="parsed")
  res <- jsonlite::fromJSON(res)

  setNames(
    meta$ili_intensity[,c("iliActivityid", "ili_activity_label", "legend")],
    c("iliactivityid", "ili_activity_label", "ili_activity_group")
  ) -> iliact

  dplyr::left_join(res$busdata, meta$stateinfo, "stateid") %>%
    dplyr::left_join(res$mmwr, "mmwrid") %>%
    dplyr::left_join(iliact, "iliactivityid") -> xdf

  xdf <- xdf[,c("statename", "ili_activity_label", "ili_activity_group",
                "statefips", "stateabbr", "weekend", "weeknumber", "year", "seasonid")]

  xdf$statefips <- trimws(xdf$statefips)
  xdf$stateabbr <- trimws(xdf$stateabbr)
  xdf$weekend <- as.Date(xdf$weekend)
  xdf$ili_activity_label <- factor(xdf$ili_activity_label,
                                   levels=iliact$ili_activity_label)

  class(xdf) <- c("tbl_df", "tbl", "data.frame")

  xdf

}

#' Retrieve metadat about U.S. State CDC Provider Data
#'
#' @md
#' @export
#' @examples
#' state_data_providers()
state_data_providers <- function() {

  jsonlite::fromJSON("https://gis.cdc.gov/grasp/fluView1/Phase1IniP") %>%
    jsonlite::fromJSON() -> meta

  state_info <- meta$stateinfo
  state_info <- state_info[,c("statename", "statehealthdeptname", "url", "statewebsitename", "statefluphonenum")]
  class(state_info) <- c("tbl_df", "tbl", "data.frame")

  state_info

}
