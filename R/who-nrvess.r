#' Retrieve WHO/NREVSS Surveillance Data
#'
#' The CDC FluView Portal provides in-season and past seasons' national, regional,
#' and state-level outpatient illness and viral surveillance data from both
#' ILINet (Influenza-like Illness Surveillance Network) and WHO/NREVSS
#' (National Respiratory and Enteric Virus Surveillance System).
#'
#' This function retrieves current and historical WHO/NREVSS surveillance data for
#' the identified region.
#'
#' @md
#' @note HHS, Census and State data retrieval is not as "instantaneous" as their ILINet
#'       counterparts.\cr\cr
#'       Also, beginning for the 2015-16 season, reports from public health and clinical
#'       laboratories are presented separately in the weekly influenza update. This is
#'       the reason why a list of data frames is returned.\cr\cr
#'       **ALSO** The new CDC API seems to be missing some public health lab data fields.
#' @param region one of "`national`", "`hhs`", "`census`", or "`state`"
#' @param years a vector of years to retrieve data for (i.e. `2014` for CDC
#'        flu season 2014-2015). CDC has data for this API going back to 1997.
#'        Default value (`NULL`) means retrieve **all** years. NOTE: if you
#'        happen to specify a 2-digit season value (i.e. `57` == 2017-2018)
#'        the function is smart enough to retrieve by season ID vs convert that
#'        to a year.
#' @return list of data frames identified by
#' - `combined_prior_to_2015_16`
#' - `public_health_labs`
#' - `clinical_labs`
#' @references
#' - [CDC FluView Portal](https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html)
#' - [ILINet Portal](https://wwwn.cdc.gov/ilinet/) (Login required)
#' - [WHO/NREVSS](https://www.cdc.gov/surveillance/nrevss/index.html)
#' @export
#' @examples \dontrun{
#' national_who <- who_nrevss("national")
#' hhs_who <- who_nrevss("hhs")
#' census_who <- who_nrevss("census")
#' state_who <- who_nrevss("state")
#' }
who_nrevss <- function(region=c("national", "hhs", "census", "state"), years=NULL) {

  region <- match.arg(tolower(region), c("national", "hhs", "census", "state"))

  meta <- jsonlite::fromJSON("https://gis.cdc.gov/grasp/flu2/GetPhase02InitApp?appVersion=Public")

  list(
    AppVersion = "Public",
    DatasourceDT = list(list(ID = 1, Name = "WHO_NREVSS")),
    RegionTypeId = .region_map[region]
  ) -> params

  params$SubRegionsDT <- switch(
    region,
    national = { list(list(ID=0, Name="")) },
    hhs = { lapply(1:10, function(i) list(ID=i, Name=as.character(i))) },
    census = { lapply(1:9, function(i) list(ID=i, Name=as.character(i))) },
    state = { lapply(1:59, function(i) list(ID=i, Name=as.character(i))) }
  )

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

  params$SeasonsDT <- lapply(years, function(i) list(ID=i, Name=as.character(i)))

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
    # httr::verbose(),
    httr::timeout(.httr_timeout),
    httr::write_disk(tf)
  ) -> res

  httr::stop_for_status(res)

  nm <- unzip(tf, overwrite = TRUE, exdir = td)

  lapply(nm, function(x) {

    tdf <- read.csv(x, skip = 1, stringsAsFactors=FALSE)
    tdf <- .mcga(tdf)
    class(tdf) <- c("tbl_df", "tbl", "data.frame")

    tdf[tdf=="X"] <- NA
    tdf[tdf=="XX"] <- NA

    tdf

  }) -> xdf

  xdf <- setNames(xdf, sub("who_nrevss_", "", tools::file_path_sans_ext(tolower(basename(nm)))))

  xdf <- lapply(xdf, function(.x) {
    x_cols <- colnames(.x)
    if ((("year" %in% x_cols) & ("week" %in% x_cols))) {
      .x$wk_date <- suppressWarnings(mmwr_week_to_date(.x$year, .x$week))
    } else {
      .x$wk_date <- as.Date(NA)
    }
    if (region == "national") .x$region <- "National"
    .x
  })

  xdf

}