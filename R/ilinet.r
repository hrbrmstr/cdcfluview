#' Retrieve ILINet Surveillance Data
#'
#' The CDC FluView Portal provides in-season and past seasons' national, regional,
#' and state-level outpatient illness and viral surveillance data from both
#' ILINet (Influenza-like Illness Surveillance Network) and WHO/NREVSS
#' (National Respiratory and Enteric Virus Surveillance System).
#'
#' This function retrieves current and historical ILINet surveillance data for
#' the identified region.
#'
#' @md
#' @param region one of "`national`", "`hhs`", "`census`", or "`state`"
#' @references
#' - [CDC FluView Portal](https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html)
#' - [ILINet Portal](https://wwwn.cdc.gov/ilinet/) (Login required)
#' - [WHO/NREVSS](https://www.cdc.gov/surveillance/nrevss/index.html)
#' @export
#' @examples
#' national_ili <- ilinet("national")
#' hhs_ili <- ilinet("hhs")
#' census_ili <- ilinet("census")
#' state_ili <- ilinet("state")
#' \dontrun{
#' library(purrr)
#' map_df(
#'   c("national", "hhs", "census", "state"),
#'   ~ilinet(.x) %>% readr::type_convert())
#' }
ilinet <- function(region=c("national", "hhs", "census", "state")) {

  region <- match.arg(tolower(region), c("national", "hhs", "census", "state"))

  list(
    AppVersion = "Public",
    DatasourceDT = list(list(ID = 1, Name = "ILINet")),
    RegionTypeId = .region_map[region]
  ) -> params

  params$SubRegionsDT <- switch(region,
    national = { list(list(ID=0, Name="")) },
    hhs = { lapply(1:10, function(i) list(ID=i, Name=as.character(i))) },
    census = { lapply(1:9, function(i) list(ID=i, Name=as.character(i))) },
    state = { lapply(1:59, function(i) list(ID=i, Name=as.character(i))) }
  )

  seasons <- 37:((unclass(as.POSIXlt(Sys.time()))[["year"]] + 1900) - 1960)
  params$SeasonsDT <- lapply(seasons, function(i) list(ID=i, Name=as.character(i)))

  tf <- tempfile(fileext = ".zip")
  td <- tempdir()

  on.exit(unlink(tf), TRUE)

  httr::POST(
    url = "https://gis.cdc.gov/grasp/flu2/PostPhase02DataDownload",
    httr::user_agent(.cdcfluview_ua),
    httr::add_headers(
      Origin = "https://gis.cdc.gov",
      Accept = "application/json, text/plain, */*",
      Referer = "https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html"
    ),
    encode = "json",
    body = params,
    httr::verbose(),
    httr::write_disk(tf)
  ) -> res

  httr::stop_for_status(res)

  nm <- unzip(tf, overwrite = TRUE, exdir = td)

  xdf <- read.csv(nm, skip = 1, stringsAsFactors=FALSE)
  xdf <- .mcga(xdf)
  class(xdf) <- c("tbl_df", "tbl", "data.frame")

  xdf[xdf=="X"] <- NA

  xdf

}