#' Age Group Distribution of Influenza Positive Tests Reported by Public Health Laboratories
#'
#' Retrieves the age group distribution of influenza positive tests that are reported by
#' public health laboratories by influenza virus type and subtype/lineage. Laboratory data
#' from multiple seasons and different age groups is provided.
#'
#' @references
#' - [CDC FluView Portal](https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html)
#' - [AGD IPT Portal](https://gis.cdc.gov/grasp/fluview/flu_by_age_virus.html)
#' @export
agd_ipt <- function() {
  httr::GET(
    url = "https://gis.cdc.gov/grasp/fluView6/GetFlu6AllDataP",
    httr::user_agent(.cdcfluview_ua),
    httr::add_headers(
      Accept = "application/json, text/plain, */*",
      Referer = "https://gis.cdc.gov/grasp/fluview/flu_by_age_virus.html"
    ),
    httr::verbose(),
    httr::timeout(60)
  ) -> res

  httr::stop_for_status(res)

  xdat <- httr::content(res, as="parsed")
  xdat <- jsonlite::fromJSON(xdat, flatten=TRUE)

  sea_names <- c("seasonid", "sea_description", "sea_startweek", "sea_endweek", "sea_enabled",
                 "sea_label", "sea_showlabtype")
  age_names <- c("ageid", "age_label", "age_color_hexvalue", "age_enabled")
  typ_names <- c("virusid", "vir_description", "vir_label", "vir_startmmwrid", "vir_endmmwrid",
                 "vir_displayorder", "vir_colorname", "vir_color_hexvalue", "vir_labtypeid",
                 "vir_sortid")
  vir_names <- c("virusid", "ageid", "count", "mmwrid", "seasonid", "publishyearweekid", "loaddatetime")

  sea_df <- stats::setNames(xdat$Season, sea_names)
  age_df <- stats::setNames(xdat$Age, age_names)
  typ_df <- stats::setNames(xdat$VirusType, typ_names)
  vir_df <- stats::setNames(xdat$VirusData, vir_names)

  vir_df <- dplyr::left_join(vir_df, sea_df, "seasonid")
  vir_df <- dplyr::left_join(vir_df, age_df, "ageid")
  vir_df <- dplyr::left_join(vir_df, typ_df, "virusid")
  class(vir_df) <- c("tbl_df", "tbl", "data.frame")

  vir_df_cols <- c("sea_label", "age_label", "vir_label", "count", "mmwrid", "seasonid",
                   "publishyearweekid", "sea_description", "sea_startweek", "sea_endweek",
                   "vir_description",  "vir_startmmwrid", "vir_endmmwrid")

  vir_df[,vir_df_cols]

}
