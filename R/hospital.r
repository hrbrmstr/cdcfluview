#' Laboratory-Confirmed Influenza Hospitalizations
#'
#' @param surveillance_area one of "`flusurv`", "`eip`", or "`ihsp`"
#' @references
#' - [Hospital Portal](https://gis.cdc.gov/GRASP/Fluview/FluHospRates.html)
#' @export
#' @examples
#' hosp_fs <- hospitalizations("flusurv")
#' hosp_eip <- hospitalizations("eip")
#' hosp_ihsp <- hospitalizations("ihsp")
hospitalizations <- function(surveillance_area=c("flusurv", "eip", "ihsp")) {

  surveillance_area <- match.arg(tolower(surveillance_area), c("flusurv", "eip", "ihsp"))

  network_id <- .hosp_surv_map[surveillance_area]

  meta <- jsonlite::fromJSON("https://gis.cdc.gov/GRASP/Flu3/GetPhase03InitApp?appVersion=Public")

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
      networkid = network_id,
      cacthmentid = "22"
      ),
    httr::verbose()
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
    dplyr::left_join(sea_df, "seasonid")

}
