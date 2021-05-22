#' Age Group Distribution of Influenza Positive Tests Reported by Public Health Laboratories
#'
#' Retrieves the age group distribution of influenza positive tests that are reported by
#' public health laboratories by influenza virus type and subtype/lineage. Laboratory data
#' from multiple seasons and different age groups is provided.
#'
#' @md
#' @references
#' - [CDC FluView Portal](https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html)
#' - [AGD IPT Portal](https://gis.cdc.gov/grasp/fluview/flu_by_age_virus.html)
#' @param years a vector of years to retrieve data for (i.e. `2014` for CDC
#'        flu season 2014-2015). CDC has data for this API going back to 1997.
#'        Default value (`NULL`) means retrieve **all** years. NOTE: if you
#'        happen to specify a 2-digit season value (i.e. `57` == 2017-2018)
#'        the function is smart enough to retrieve by season ID vs convert that
#'        to a year.
#' @export
#' @examples
#' agd <- age_group_distribution(years=2015)
age_group_distribution <- function(years = NULL) {

  httr::GET(
    url = "https://gis.cdc.gov/grasp/fluView6/GetFlu6AllDataP",
    httr::user_agent(.cdcfluview_ua),
    httr::add_headers(
      Accept = "application/json, text/plain, */*",
      Referer = "https://gis.cdc.gov/grasp/fluview/flu_by_age_virus.html"
    ),
    # httr::verbose(),
    httr::timeout(.httr_timeout)
  ) -> res

  httr::stop_for_status(res)

  xdat <- httr::content(res, as="parsed")
  xdat <- jsonlite::fromJSON(xdat, flatten=TRUE)

  sea_names <- c("seasonid", "sea_description", "sea_startweek", "sea_endweek", "sea_enabled",
                 "sea_label", "sea_showlabtype", "incl_wkly_rates_and_strata")
  age_names <- c("ageid", "age_label", "age_color_hexvalue", "age_enabled")
  typ_names <- c("virusid", "vir_description", "vir_label", "vir_startmmwrid", "vir_endmmwrid",
                 "vir_displayorder", "vir_colorname", "vir_color_hexvalue", "vir_labtypeid",
                 "vir_sortid")
  vir_names <- c("virusid", "ageid", "count", "mmwrid", "seasonid")

  sea_df <- stats::setNames(xdat$Season, sea_names)
  age_df <- stats::setNames(xdat$Age, age_names)
  typ_df <- stats::setNames(xdat$VirusType, typ_names)
  vir_df <- stats::setNames(xdat$VirusData, vir_names)

  vir_df <- dplyr::left_join(vir_df, sea_df, "seasonid")
  vir_df <- dplyr::left_join(vir_df, age_df, "ageid")
  vir_df <- dplyr::left_join(vir_df, typ_df, "virusid")

  class(vir_df) <- c("tbl_df", "tbl", "data.frame")

  vir_df_cols <- c("sea_label", "age_label", "vir_label", "count", "mmwrid", "seasonid",
                   "sea_description", "sea_startweek",
                   "sea_endweek", "vir_description",  "vir_startmmwrid", "vir_endmmwrid")

  vir_df <- vir_df[,vir_df_cols]

  vir_df$age_label <- factor(vir_df$age_label, levels=.age_grp)
  vir_df$vir_label <- factor(vir_df$vir_label, levels=.vir_grp)

  vir_df <- dplyr::left_join(vir_df, mmwrid_map, "mmwrid")

  available_seasons <- sort(unique(vir_df$seasonid))

  if (!is.null(years)) { # specified years or seasons or a mix

    years <- as.numeric(years)
    years <- ifelse(years > 1996, years - 1960, years)
    years <- sort(unique(years))
    years <- years[years %in% available_seasons]

    if (length(years) == 0) {
      years <- rev(available_seasons)[1]
      curr_season_descr <- vir_df[vir_df$seasonid == years,]$sea_description[1]
      message(sprintf("No valid years specified, defaulting to this flu season => ID: %s [%s]",
                      years, curr_season_descr))
    }

    vir_df <- dplyr::filter(vir_df, seasonid %in% years)

  }

  vir_df

}
