#' State and Territorial Epidemiologists Reports of Geographic Spread of Influenza
#'
#' @export
#' @examples \dontrun{
#' geographic_spread()
#' }
geographic_spread <- function() {

  meta <- jsonlite::fromJSON("https://gis.cdc.gov/grasp/Flu8/GetPhase08InitApp?appVersion=Public")

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
      SeasonIDs = paste0(meta$seasons$seasonid, collapse=",")
    ),
    # httr::verbose(),
    httr::timeout(60)
  ) -> res

  httr::stop_for_status(res)

  res <- httr::content(res, as="parsed", flatten=TRUE)

  xdf <- dplyr::bind_rows(res$datadownload)
  xdf$weekend <- as.Date(xdf$weekend, format="%B-%d-%Y")

  xdf

}
