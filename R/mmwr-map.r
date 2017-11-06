# THIS IS NOT EXPORTED FROM MMWRweek but I need it
# Find start date for a calendar year
#
# Finds the state date given a numeric calendar year
# @author Jarad Niemi \email{niemi@@iastate.edu}
.start_date = function(year) {
  # Finds start state for this calendar year
  jan1 = as.Date(paste(year, '-01-01', sep=''))
  wday = as.numeric(MMWRweekday(jan1))
  jan1 - (wday-1) + 7*(wday>4)
}

# I discovered why 1962!: https://www.cdc.gov/mmwr/preview/mmwrhtml/su6004a9.htm
.tmp <- lapply(1962:2050, .start_date)

mapply(function(.x, .y) {
  data_frame(
    wk_start = seq(.tmp[[.x]], .tmp[[.y]], "1 week"),
    wk_end = wk_start + 6,
    year_wk_num = 1:length(wk_start)
  ) -> tmp
  tmp[-nrow(tmp),]
}, 1:(length(.tmp)-1), 2:length(.tmp), SIMPLIFY=FALSE) -> mmwrid_map

mmwrid_map <- Reduce(rbind.data.frame, mmwrid_map)
mmwrid_map$mmwrid <- 1:nrow(mmwrid_map)

#' @title MMWR ID to Calendar Mappings
#' @md
#' @description The CDC uses a unique "Morbidity and Mortality Weekly Report" identifier
#'     for each week that starts at 1 (Ref: < https://www.cdc.gov/mmwr/preview/mmwrhtml/su6004a9.htm>).
#'     This data frame consists of 4 columns:
#' - `wk_start`: Start date (Sunday) for the week (`Date`)
#' - `wk_end`: End date (Saturday) for the week (`Date`)
#' - `year_wk_num`: The week of the calendar year
#' - `mmwrid`: The unique MMWR identifier
#' These can be "left-joined" to data provided from the CDC to perform MMWR identifier
#' to date mappings.
#' @docType data
#' @name mmwrid_map
#' @format A data frame with 4,592 rows and 4 columns
#' @export
NULL

#' Convert a Date to an MMWR day+week+year
#'
#' This is a reformat and re-export of a function in the `MMWRweek` package.
#' It provides a snake case version of its counterpart, produces a `tibble`
#'
#' @md
#' @param x a vector of `Date` objects or a character vector in `YYYY-mm-dd` format.
#' @return data frame (tibble)
#' @export
#' @examples
#' mmwr_week(Sys.Date())
mmwr_week <- function(x) {
  x <- as.Date(x)
  x <- setNames(MMWRweek::MMWRweek(x), c("mmwr_year", "mmwr_week", "mmwr_day"))
  class(x) <- c("tbl_df", "tbl", "data.frame")
  x
}

#' Convert a Date to an MMWR weekday
#'
#' This is a reformat and re-export of a function in the `MMWRweek` package.
#' It provides a snake case version of its counterpart, produces a `factor` of
#' weekday names (Sunday-Saturday).
#'
#' @md
#' @note Weekday names are explicitly mapped to "Sunday-Saturday" or "Sun-Sat" and
#'       do not change with your locale.
#' @param x a vector of `Date` objects or a character vector in `YYYY-mm-dd` format.
#' @param abbr (logical) if `TRUE`, return abbreviated weekday names, otherwise full
#'     weekday names (see Note).
#' @return ordered factor
#' @export
#' @examples
#' mmwr_weekday(Sys.Date())
mmwr_weekday <- function(x, abbr = FALSE) {
  x <- as.Date(x)
  x <- MMWRweek::MMWRweekday(x)
  if (abbr) {
    x <- ordered(
      x,
      levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"),
      labels = c("Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat")
    )
  }
  x
}

#' Convert an MMWR year+week or year+week+day to a Date object
#'
#' This is a reformat and re-export of a function in the `MMWRweek` package.
#' It provides a snake case version of its counterpart and produces a vector
#' of `Date` objects that corresponds to the input MMWR year+week or year+week+day
#' vectors. This also adds some parameter checking and cleanup to avoid exceptions.
#'
#' @md
#' @param year,week,day Year, week and month vectors. All must be the same length
#'        unless `day` is `NULL`.
#' @return vector of `Date` objects
#' @export
#' @examples
#' mmwr_week_to_date(2016,10,3)
mmwr_week_to_date <- function(year, week, day=NULL) {

  year <- as.numeric(year)
  week <- as.numeric(week)
  day <- if (!is.null(day)) as.numeric(day) else rep(1, length(week))

  week <- ifelse(0 < week & week < 54, week, NA)

  as.Date(ifelse(is.na(week), NA, MMWRweek::MMWRweek2Date(year, week, day)),
          origin="1970-01-01")

}








