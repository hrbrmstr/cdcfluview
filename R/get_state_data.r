#' Retrieves state/territory-level influenza statistics from the CDC
#'
#' Uses the data source from the CDC' State-levelFluView
#' \url{http://gis.cdc.gov/grasp/fluview/main.html} and provides state flu
#' reporting data as a single data frame.\cr
#' \cr
#' This function provides similar data to \code{\link{get_weekly_flu_report}} but
#' provides more metadata about the reporting sources and has access to more
#' historical infomation.
#'
#' @param years a vector of years to retrieve data for (i.e. \code{2014} for CDC
#'        flu season 2014-2015). Default value is the current year and all
#'        \code{years} values should be > \code{1997}
#' @return A \code{data.frame} of state-level data for the specified seasons
#'         (also classed as \code{cdcstatedata})
#' @export
#' @note There is often a noticeable delay when making the API request to the CDC. This
#'       is not due to a large download size, but the time it takes for their
#'       servers to crunch the data. Wrap the function call in \code{httr::with_verbose}
#'       if you would like to see what's going on.
#' @examples \dontrun{
#' get_state_dat(2014)
#' get_state_data(c(2013, 2014))
#' get_state_data(2010:2014)
#' httr::with_verbose(get_state_data(2009:2015))
#' }
get_state_data <- function(years=as.numeric(format(Sys.Date(), "%Y"))) {

  if (any(years < 1997))
    stop("Error: years should be > 1997")

  years <- years - 1960

  out_file <- tempfile(fileext=".zip")

  params <- list(EndMMWRID=0,
                 StartMMWRID=0,
                 QueryType=1,
                 DataMode="STATE",
                 SeasonsList=paste0(years, collapse=","))

  tmp <- POST("http://gis.cdc.gov/grasp/fluview/FluViewPhase1CustomDownload.ashx",
              body=params,
              write_disk(out_file))

  stop_for_status(tmp)

  if (!(file.exists(out_file)))
    stop("Error: cannot process downloaded data")

  out_dir <- tempdir()

  files <- unzip(out_file, exdir=out_dir, overwrite=TRUE)

  out <- read.csv(files, header=TRUE, stringsAsFactors=FALSE)

  class(out) <- c("cdcstatedata", class(out))

  out

}
