#' Retrieve weekly state-level ILI indicators per-state for a given season
#'
#' @md
#' @param years a vector of years to retrieve data for (i.e. `2014` for CDC
#'        flu season 2014-2015). CDC has data for this API going back to 2008
#'        and up until the current, active flu season.
#'        Default value (`NULL`) means retrieve **all** years. NOTE: if you
#'        happen to specify a 2-digit season value (i.e. `57` == 2017-2018)
#'        the function is smart enough to retrieve by season ID vs convert that
#'        to a year.
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
#' iwai <- ili_weekly_activity_indicators(2016)
#' }
ili_weekly_activity_indicators <- function(years=NULL) {

  meta <- jsonlite::fromJSON("https://gis.cdc.gov/grasp/fluView1/Phase1IniP")
  meta <- jsonlite::fromJSON(meta)

  available_seasons <- sort(meta$seasons$seasonid)

  if (is.null(years)) { # ALL YEARS
    years <- available_seasons
  } else { # specified years or seasons or a mix

    years <- as.numeric(years)
    years <- ifelse(years > 1996, years - 1960, years)
    years <- sort(unique(years))
    years <- years[years %in% available_seasons]

    if (length(years) == 0) {
      years <- rev(sort(meta$seasons$seasonid))[1]
      curr_season_descr <- meta$seasons[meta$seasons$seasonid == years, "description"]
      message(sprintf("No valid years specified, defaulting to this flu season => ID: %s [%s]",
                      years, curr_season_descr))
    }

  }

  years <- paste0(c(years, 1), collapse=",") # the API seems to use '1' as a sentinel

  res <- httr::GET(sprintf("https://gis.cdc.gov/grasp/fluView1/Phase1DownloadDataP/%s",
                           years))

  httr::stop_for_status(res)

  xdf <- httr::content(res, as="parsed")
  xdf <- jsonlite::fromJSON(xdf)
  xdf <- xdf$datadownload

  suppressMessages(xdf$weekend <- as.Date(xdf$weekend, "%b-%d-%Y"))
  suppressMessages(xdf$weeknumber <- as.numeric(xdf$weeknumber))
  suppressMessages(xdf$activity_level <- as.numeric(xdf$activity_level))

  class(xdf) <- c("tbl_df", "tbl", "data.frame")

  xdf

}

#' Retrieve metadata about U.S. State CDC Provider Data
#'
#' @md
#' @export
#' @examples
#' sdp <- state_data_providers()
state_data_providers <- function() {

  jsonlite::fromJSON("https://gis.cdc.gov/grasp/fluView1/Phase1IniP") %>%
    jsonlite::fromJSON() -> meta

  state_info <- meta$stateinfo
  state_info <- state_info[,c("statename", "statehealthdeptname", "url", "statewebsitename", "statefluphonenum")]
  class(state_info) <- c("tbl_df", "tbl", "data.frame")

  state_info

}
