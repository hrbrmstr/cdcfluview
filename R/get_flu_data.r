#' Retrieves state, regional or national influenza statistics from the CDC
#'
#' Uses the data source from the
#' \href{https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html}{CDC FluView}
#' and provides flu reporting data as either a single data frame or a list of
#' data frames (depending on whether either \code{WHO NREVSS} or \code{ILINet}
#' (or both) is chosen.
#'
#' A lookup table between HHS regions and their member states/territories
#' is provided in \code{\link{hhs_regions}}.
#'
#' @param region one of "\code{hhs}", "\code{census}", "\code{national}"
#' @param sub_region depends on the \code{region_type}.\cr
#'        For "\code{national}", the \code{sub_region} should be \code{NA}.\cr
#'        For "\code{hhs}", should be a vector between \code{1:10}.\cr
#'        For "\code{census}", should be a vector between \code{1:9}
#' @param data_source either of "\code{who}" (for WHO NREVSS) or "\code{ilinet}"
#'        or "\code{all}" (for both)
#' @param years a vector of years to retrieve data for (i.e. \code{2014} for CDC
#'        flu season 2014-2015). Default value is the current year and all
#'        \code{years} values should be > \code{1997}
#' @return If only a single \code{data_source} is specified, then a single
#'         \code{data.frame} is returned, otherwise a named list with each
#'         \code{data.frame} is returned.
#' @note There is often a noticeable delay when making the API request to the CDC.
#'       This is not due to a large download size, but the time it takes for their
#'       servers to crunch the data. Wrap the function call in \code{httr::with_verbose}
#'       if you would like to see what's going on.
#' @export
#' @examples \dontrun{
#' flu <- get_flu_data("hhs", 1:10, c("who", "ilinet"), years=2000:2014)
#' }
get_flu_data <- function(region="hhs", sub_region=1:10,
                         data_source="ilinet",
                         years=as.numeric(format(Sys.Date(), "%Y"))) {

  region <- tolower(region)
  data_source <- tolower(data_source)

  if (!(region %in% c("hhs", "census", "national")))
    stop("Error: region must be one of hhs, census or national")

  if (length(region) != 1)
    stop("Error: can only select one region")

  if (region=="national") sub_region = ""

  if ((region=="hhs") && !all(sub_region %in% 1:10))
    stop("Error: sub_region values must fall between 1:10 when region is 'hhs'")

  if ((region=="census") && !all(sub_region %in% 1:19))
    stop("Error: sub_region values must fall between 1:10 when region is 'census'")

  if (!all(data_source %in% c("who", "ilinet", "all")))
    stop("Error: data_source must be either 'who', 'ilinet', 'all' or c('who', 'ilinet')")

  if (any(years < 1997))
    stop("Error: years should be > 1997")

  # format the input parameters to fit the CDC API

  years <- years - 1960

  reg <- as.numeric(c("hhs"=1, "census"=2, "national"=3)[[region]])

  if ("all" %in% data_source) data_source <- c("who", "ilinet")

  data_source <- gsub("who", "WHO_NREVSS", data_source)
  data_source <- gsub("ilinet", "ILINet", data_source)

  params <- list(SubRegionsList=paste0(sub_region, collapse=","),
                 DataSources=paste0(data_source, collapse=","),
                 RegionID=reg,
                 SeasonsList=paste0(years, collapse=","))

  out_file <- tempfile(fileext=".zip")

  tmp <- httr::POST("https://gis.cdc.gov/grasp/fluview/FluViewPhase2CustomDownload.ashx",
                    body=params,
                    write_disk(out_file))

  stop_for_status(tmp)

  if (!(file.exists(out_file)))
    stop("Error: cannot process downloaded data")

  out_dir <- tempdir()

  files <- unzip(out_file, exdir=out_dir, overwrite=TRUE)

  pb <- dplyr::progress_estimated(length(files))
  purrr::map(files, function(x) {
    pb$tick()$print()
    ct <- ifelse(grepl("who", x, ignore.case=TRUE), 1, 1)
    suppressMessages(readr::read_csv(x, skip=ct))
  }) -> file_list

  names(file_list) <- substr(basename(files), 1, 3)

  if (length(file_list) == 1) {
    return(file_list[[1]])
  } else {
    return(file_list)
  }

}
