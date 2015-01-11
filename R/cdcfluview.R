# http://gis.cdc.gov/grasp/fluview/fluportaldashboard.html

#' Retrieve CDC flu data
#'
#' Uses the data source from the CDC FluView \url{http://gis.cdc.gov/grasp/fluview/fluportaldashboard.html}
#' and provides flu reporting data as either a single data frame or a list
#' of data frames (depending on whether either WHO NREVSS or ILINet - or both - is chosen)
#'
#' @param region one of "\code{hhs}", "\code{census}", "\code{national}"
#' @param sub_region depends on the \code{region_type}.\cr
#'        For "\code{national}", the \code{sub_region} should be \code{NA}.\cr
#'        For "\code{hhs}", should be a vector between \code{1:10}.\cr
#'        For "\code{census}", should be a vector between \code{1:9}
#' @param data_source either of "\code{who}" (for WHO NREVSS) or "\code{ilinet}" or "\code{all}" (for both)
#' @param years a vector of years to retrieve data for (i.e. \code{2014} for CDC flu seasn 2014-2015)
#' @return If only a single \code{data_source} is specified, then a single \code{data.frame} is
#'         returned, otherwise a named list with each \code{data.frame} is returned.
#' @export
#' @examples \dontrun{
#' flu <- get_flu_data("hhs", 1:10, c("who", "ilinet"), years=2000:2014)
#' }
get_flu_data <- function(region="hhs", sub_region=1:10,
                         data_source="ilinet", years=2014) {

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

  if (!all(data_source %in% c("who", "ilinet")))
    stop("Error: data_source must be either 'who', 'ilinet' or both")

  if (any(years < 1997))
    stop("Error: years should be > 1997")

  years <- years - 1960

  reg <- as.numeric(c("hhs"=1, "census"=2, "national"=3)[[region]])
  data_source <- gsub("who", "WHO_NREVSS", data_source)
  data_source <- gsub("ilinet", "ILINet", data_source)

  params <- list(SubRegionsList=sub_region,
                 DataSources=data_source,
                 RegionID=reg,
                 SeasonsList=years)

  out_file <- tempfile(fileext=".zip")

  tmp <- POST("http://gis.cdc.gov/grasp/fluview/FluViewPhase2CustomDownload.ashx",
              body=params,
              write_disk(out_file))

  stop_for_status(tmp)

  if (!(file.exists(out_file)))
    stop("Error: cannot process downloaded data")

  out_dir <- tempdir()

  files <- unzip(out_file, exdir=out_dir, overwrite=TRUE)

  file_list <- lapply(files, function(x) {
    ct <- ifelse(grepl("who", x, ignore.case=TRUE), 0, 1)
    read.csv(x, header=TRUE, skip=ct, stringsAsFactors=FALSE)
  })

  names(file_list) <- substr(basename(files), 1, 3)

  if (length(file_list) == 1) {
    return(file_list[[1]])
  } else {
    return(file_list)
  }

}
