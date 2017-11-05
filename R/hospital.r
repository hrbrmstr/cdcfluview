#' Laboratory-Confirmed Influenza Hospitalizations
#'
#' @md
#' @param surveillance_area one of "`flusurv`", "`eip`", or "`ihsp`"
#' @param region Using "`all`" mimics selecting "Entire Network" from the
#'        CDC FluView application drop down. Individual regions for each
#'        surveillance area can also be selected. Use [surveillance_areas()] to
#'        see a list of valid sub-regions for each surveillance area.
#' @references
#' - [Hospital Portal](https://gis.cdc.gov/GRASP/Fluview/FluHospRates.html)
#' @export
#' @examples \dontrun{
#' hosp_fs <- hospitalizations("flusurv")
#' hosp_eip <- hospitalizations("eip")
#' hosp_ihsp <- hospitalizations("ihsp")
#' }
hospitalizations <- function(surveillance_area=c("flusurv", "eip", "ihsp"),
                             region="all") {

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
    httr::timeout(60)
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
    )

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
