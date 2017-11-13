#' Laboratory-Confirmed Influenza Hospitalizations
#'
#' @md
#' @param surveillance_area one of "`flusurv`", "`eip`", or "`ihsp`"
#' @param region Using "`all`" mimics selecting "Entire Network" from the
#'        CDC FluView application drop down. Individual regions for each
#'        surveillance area can also be selected. Use [surveillance_areas()] to
#'        see a list of valid sub-regions for each surveillance area.
#' @param years a vector of years to retrieve data for (i.e. `2014` for CDC
#'        flu season 2014-2015). CDC has data for this API going back to 2009
#'        and up until the _previous_ flu season.
#'        Default value (`NULL`) means retrieve **all** years. NOTE: if you
#'        happen to specify a 2-digit season value (i.e. `56` == 2016-2017)
#'        the function is smart enough to retrieve by season ID vs convert that
#'        to a year.
#' @references
#' - [Hospital Portal](https://gis.cdc.gov/GRASP/Fluview/FluHospRates.html)
#' @export
#' @examples 
#' hosp_fs <- hospitalizations("flusurv", years=2015)
#' \dontrun{
#' hosp_eip <- hospitalizations("eip")
#' hosp_ihsp <- hospitalizations("ihsp")
#' }
hospitalizations <- function(surveillance_area=c("flusurv", "eip", "ihsp"),
                             region="all", years=NULL) {

  sarea <- match.arg(tolower(surveillance_area), choices = c("flusurv", "eip", "ihsp"))
  sarea <- .surv_rev_map[sarea]

  meta <- jsonlite::fromJSON("https://gis.cdc.gov/GRASP/Flu3/GetPhase03InitApp?appVersion=Public")
  areas <- setNames(meta$catchments[,c("networkid", "name", "area", "catchmentid")],
                    c("networkid", "surveillance_area", "region", "id"))

  reg <- region
  if (reg == "all") reg <- "Entire Network"

  tgt <- dplyr::filter(areas, (surveillance_area == sarea) & (region == reg))

  if (nrow(tgt) == 0) {
    stop("Region not found. Use `surveillance_areas()` to see a list of valid inputs.",
         call.=FALSE)
  }

  httr::POST(
    url = "https://gis.cdc.gov/GRASP/Flu3/PostPhase03GetData",
    httr::user_agent(.cdcfluview_ua),
    httr::add_headers(
      Origin = "https://gis.cdc.gov",
      Accept = "application/json, text/plain, */*",
      Referer = "https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html"
    ),
    encode = "json",
    body = list(
      appversion = "Public",
      networkid = tgt$networkid,
      cacthmentid = tgt$id
    ),
    # httr::verbose(),
    httr::timeout(.httr_timeout)
  ) -> res

  httr::stop_for_status(res)

  res <- httr::content(res)

  hosp <- list(res = res, meta = meta)

  age_df <- setNames(hosp$meta$ages, c("age_label", "age", "color"))
  age_df <- age_df[,c("age", "age_label")]

  sea_df <- setNames(
    hosp$meta$seasons,
    c("sea_description", "sea_endweek", "sea_label", "seasonid", "sea_startweek", "color", "color_hexvalue"))
  sea_df <- sea_df[,c("seasonid", "sea_label", "sea_description", "sea_startweek", "sea_endweek")]

  ser_names <- unlist(hosp$res$busdata$datafields, use.names = FALSE)

  mmwr_df <- bind_rows(hosp$res$mmwr)
  mmwr_df <- mmwr_df[,c("mmwrid", "weekend", "weeknumber", "weekstart", "year",
                        "yearweek", "seasonid", "weekendlabel", "weekendlabel2")]

  dplyr::bind_rows(lapply(hosp$res$busdata$dataseries, function(.x) {
    tdf <- dplyr::bind_rows(lapply(.x$data, function(.x) setNames(.x, ser_names)))
    tdf$age <- .x$age
    tdf$season <- .x$season
    tdf
  })) -> xdf

  dplyr::left_join(xdf, mmwr_df, c("mmwrid", "weeknumber")) %>%
    dplyr::left_join(age_df, "age") %>%
    dplyr::left_join(sea_df, "seasonid") %>%
    dplyr::mutate(
      surveillance_area = sarea,
      region = reg
    ) %>%
    dplyr::left_join(mmwrid_map, "mmwrid") -> xdf

  xdf$age_label <- factor(xdf$age_label,
                          levels=c("0-4 yr", "5-17 yr", "18-49 yr", "50-64 yr",
                                   "65+ yr", "Overall"))

  xdf <- xdf[,c("surveillance_area", "region", "year", "season", "wk_start", "wk_end",
                "year_wk_num", "rate", "weeklyrate", "age", "age_label", "sea_label",
                "sea_description", "mmwrid")]

  available_seasons <- sort(unique(xdf$season))

  if (!is.null(years)) { # specified years or seasons or a mix

    years <- as.numeric(years)
    years <- ifelse(years > 1996, years - 1960, years)
    years <- sort(unique(years))
    years <- years[years %in% available_seasons]

    if (length(years) == 0) {
      years <- rev(available_seasons)[1]
      curr_season_descr <- xdf[xdf$season == years,]$sea_description[1]
      message(
        sprintf(
          "No valid years specified, defaulting to the last available flu season => ID: %s [%s]",
          years, curr_season_descr
        )
      )
    }

    xdf <- dplyr::filter(xdf, season %in% years)

  }

  xdf

}

#' Retrieve a list of valid sub-regions for each surveillance area.
#'
#' @md
#' @export
#' @examples
#' surveillance_areas()
surveillance_areas <- function() {
  meta <- jsonlite::fromJSON("https://gis.cdc.gov/GRASP/Flu3/GetPhase03InitApp?appVersion=Public")
  xdf <- setNames(meta$catchments[,c("name", "area")], c("surveillance_area", "region"))
  xdf$surveillance_area <- .surv_map[xdf$surveillance_area]
  xdf
}
