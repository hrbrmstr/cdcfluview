#' State and Territorial Epidemiologists Reports of Geographic Spread of Influenza
#'
#' @md
#' @param years a vector of years to retrieve data for (i.e. `2014` for CDC
#'        flu season 2014-2015). CDC has data for this API going back to 2003
#'        and up until the current, active flu season.
#'        Default value (`NULL`) means retrieve **all** years. NOTE: if you
#'        happen to specify a 2-digit season value (i.e. `57` == 2017-2018)
#'        the function is smart enough to retrieve by season ID vs convert that
#'        to a year.
#' @export
#' @examples \dontrun{
#' gs <- geographic_spread()
#' }
geographic_spread <- function(years=NULL) {

  meta <- jsonlite::fromJSON("https://gis.cdc.gov/grasp/Flu8/GetPhase08InitApp?appVersion=Public")

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

  httr::POST(
    url = "https://gis.cdc.gov/grasp/Flu8/PostPhase08DownloadData",
    httr::user_agent(.cdcfluview_ua),
    httr::add_headers(
      Origin = "https://gis.cdc.gov",
      Accept = "application/json, text/plain, */*",
      Referer = "https://gis.cdc.gov/grasp/fluview/FluView8.html"
    ),
    encode = "json",
    body = list(
      AppVersion = "Public",
      SeasonIDs = paste0(years, collapse=",")
    ),
    # httr::verbose(),
    httr::timeout(.httr_timeout)
  ) -> res

  httr::stop_for_status(res)

  res <- httr::content(res, as="parsed", flatten=TRUE)

  suppressMessages(suppressWarnings(xdf <- dplyr::bind_rows(res$datadownload)))
  xdf$weekend <- as.Date(xdf$weekend, format="%B-%d-%Y")

  xdf

}
