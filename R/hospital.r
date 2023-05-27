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

  meta <- .get_meta()

  # meta <- jsonlite::fromJSON("https://gis.cdc.gov/GRASP/Flu3/GetPhase03InitApp?appVersion=Public")
  areas <- setNames(meta$catchments[,c("networkid", "name", "area", "catchmentid")],
                    c("networkid", "surveillance_area", "region", "id"))

  reg <- region
  if (reg == "all") reg <- "Entire Network"

  tgt <- dplyr::filter(areas, (surveillance_area == sarea) & (region == reg))

  if (nrow(tgt) == 0) {
    stop("Region not found. Use `surveillance_areas()` to see a list of valid inputs.",
         call.=FALSE)
  }

  hosp <- list(res = meta$default_data, meta = meta)

  age_df <- setNames(hosp$meta$master_lookup, c("variable", "value_id", "parent_id", "label", "color", "enabled"))
  age_df <- age_df[(age_df$variable == "Age" | age_df$value_id == 0) & !is.na(age_df$value_id),]
  age_df <- setNames(age_df[,c("value_id", "label")], c("ageid", "age_label"))
  age_df <- age_df[order(age_df$ageid),]

  race_df <- setNames(hosp$meta$master_lookup, c("variable", "value_id", "parent_id", "label", "color", "enabled"))
  race_df <- race_df[(race_df$variable == "Race" | race_df$value_id == 0) & !is.na(race_df$value_id),]
  race_df <- setNames(race_df[,c("value_id", "label")], c("raceid", "race_label"))

  season_df <- setNames(
    hosp$meta$seasons,
    c("season_description", "season_enabled", "season_endweek", "season_label", "seasonid", "season_startweek", "include_weekly")
  )
  season_df <- season_df[,c("seasonid", "season_label", "season_description", "season_startweek", "season_endweek")]

  mmwr_df <- hosp$meta$mmwr
  mmwr_df <- mmwr_df[,c("mmwrid", "weekend", "weeknumber", "weekstart", "year",
                        "yearweek", "seasonid", "weekendlabel", "weekendlabel2")]

  catchments_df <- hosp$meta$catchments[,c("catchmentid", "beginseasonid", "endseasonid", "networkid", "name", "area")]

  # if (length(unique(xdf$age)) > 9) {
  #   data.frame(
  #     age = 1:12,
  #     age_label = c("0-4 yr", "5-17 yr", "18-49 yr", "50-64 yr", "65+ yr", "Overall",
  #                   "65-74 yr", "75-84 yr", "85+", "18-29 yr", "30-39 yr", "40-49 yr"
  #     )
  #   ) -> age_df
  #   age_df$age_label <- factor(age_df$age_label, levels = age_df$age_label)
  # }

  xdf <- hosp$res

  mmwr_df$seasonid <- NULL
  xdf <- dplyr::left_join(xdf, mmwr_df, "mmwrid")

  xdf <- dplyr::left_join(xdf, age_df, "ageid")
  xdf <- dplyr::left_join(xdf, race_df, "raceid")
  xdf <- dplyr::left_join(xdf, season_df, "seasonid")

  xdf$catchmentid <- as.character(xdf$catchmentid)
  catchments_df$catchmentid <- as.character(catchments_df$catchmentid)
  catchments_df$networkid <- NULL
  xdf <- dplyr::left_join(xdf, catchments_df, "catchmentid")

  xdf$surveillance_area <- sarea
  xdf$region <- reg

#   xdf <- xdf[,c("surveillance_area", "region", "year", "season", "wk_start", "wk_end",
#                 "year_wk_num", "rate", "weeklyrate", "age", "age_label", "sea_label",
#                 "sea_description", "mmwrid")]

  available_seasons <- sort(unique(xdf$seasonid))

  if (!is.null(years)) { # specified years or seasons or a mix

    years <- as.numeric(years)
    years <- ifelse(years > 1996, years - 1960, years)
    years <- sort(unique(years))
    years <- years[years %in% available_seasons]

    if (length(years) == 0) {
      years <- rev(available_seasons)[1]
      curr_season_descr <- xdf[xdf$seasonid == years,]$season_description[1]
      message(
        sprintf(
          "No valid years specified, defaulting to the last available flu season => ID: %s [%s]",
          years, curr_season_descr
        )
      )
    }

    xdf <- xdf[xdf$seasonid %in% years, ]

  }

  xdf

}

#' Retrieve a list of valid sub-regions for each surveillance area.
#'
#' @md
#' @export
#' @examples
#' sa <- surveillance_areas()
surveillance_areas <- function() {
  meta <- .get_meta()
  xdf <- setNames(meta$catchments[,c("name", "area")], c("surveillance_area", "region"))
  xdf$surveillance_area <- .surv_map[xdf$surveillance_area]
  xdf
}
