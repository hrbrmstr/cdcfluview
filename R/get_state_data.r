#' Retrieves state/territory-level influenza statistics from the CDC
#'
#' Uses the data source from the CDC' State-levelFluView
#' \url{https://gis.cdc.gov/grasp/fluview/main.html} and provides state flu
#' reporting data as a single data frame.\cr
#' \cr
#' This function provides similar data to \code{\link{get_weekly_flu_report}} but
#' provides more metadata about the reporting sources and has access to more
#' historical infomation.
#'
#' @param years a vector of years to retrieve data for (i.e. \code{2014} for CDC
#'        flu season 2014-2015). Default value is the current year and all
#'        \code{years} values should be >= \code{2008}
#' @return A \code{data.frame} of state-level data for the specified seasons
#'         (also classed as \code{cdcstatedata})
#' @export
#' @note There is often a noticeable delay when making the API request to the CDC. This
#'       is not due to a large download size, but the time it takes for their
#'       servers to crunch the data. Wrap the function call in \code{httr::with_verbose}
#'       if you would like to see what's going on.
#' @examples \dontrun{
#' get_state_data(2014)
#' get_state_data(c(2013, 2014))
#' get_state_data(2010:2014)
#' httr::with_verbose(get_state_data(2009:2015))
#' }
get_state_data <- function(years=as.numeric(format(Sys.Date(), "%Y"))) {

  if (any(years < 2008))
    stop("Error: years should be >= 2008")

  years <- c((years - 1960), 1)
  years <- paste0(years, collapse=",")

  tmp <- httr::GET(sprintf("https://gis.cdc.gov/grasp/fluView1/Phase1DownloadDataP/%s", years))

  stop_for_status(tmp)

  res <- httr::content(tmp, as="parsed")

  ctx <- V8::v8()
  ctx$eval(V8::JS(sprintf("var dat=%s;", res)))
  res <- ctx$get("dat", flatten=FALSE)
  out <- suppressMessages(readr::type_convert(res$datadownload))

  class(out) <- c("cdcstatedata", class(out))

  out

}
