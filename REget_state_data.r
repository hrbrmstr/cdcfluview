
#' Retrieves the state-level data from the CDC's FluView Portal
#'
#' Uses the data source from the CDC' State-levelFluView \url{http://gis.cdc.gov/grasp/fluview/main.html}
#' and provides state flu reporting data as a single data frame
#'
#' @param years a vector of years to retrieve data for (i.e. \code{2014} for CDC flu season 2014-2015)
#' @return A \code{data.frame} of state-level data for the specified seasons
#' @export
#' @examples \dontrun{
#' get_state_dat(2014)
#' get_state_data(c(2013, 2014))
#' }
get_state_data <- function(years=2014) {

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

  read.csv(files, header=TRUE, stringsAsFactors=FALSE)

}
