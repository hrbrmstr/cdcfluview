#' Mortality Surveillance Data from the National Center for Health Statistics (deprecated)
#'
#' The National Center for Health Statistics (NCHS) collects and disseminates the Nation's
#' official vital statistics. These statistics are based on data provided to NCHS through
#' contracts with the vital registration systems operated in the various jurisdictions
#' legally responsible for the registration of deaths (i.e., death certificates) and other
#' vital events. These data have previously only been released as annual final data files
#' 12 months or more after the end of the data year. Recent NCHS efforts to improve the
#' timeliness of jurisdiction reporting and modernize the national vital statistics
#' infrastructure have created a system capable of supporting near real-time surveillance.
#' Capitalizing on these new capabilities, NCHS and CDC’s Influenza Division have
#' partnered to pilot the use of NCHS mortality surveillance data for Pneumonia and
#' Influenza (P&I) mortality surveillance.
#'
#' NCHS mortality surveillance data are presented by the week the death occurred.
#' Nationally P&I percentages are released two weeks after the week of death to allow for
#' collection of enough data to produce a stable P&I percentage at the national level.
#' Collection of complete data is not expected, and reliable P&I ratios are not expected
#' at the region and state level within this two week period. State and Region level
#' counts will be released only after 20% of the expected number of deaths are reported
#' through the system.
#'
#' @references \url{https://www.cdc.gov/flu/weekly/nchs.htm}
#' @return a list of \code{tbl_df}s
#' @export
#' @examples \dontrun{
#' get_mortality_surveillance_data()
#' }
get_mortality_surveillance_data <- function() {

  message(
    paste0(
      c("This function has been deprecated and will be removed in future releases.",
        "Use pi_mortality() instead."),
      collapse="\n"
    )
  )

  # scrape (ugh) web page to get data file links for state mortality data

  pg <- xml2::read_html("https://www.cdc.gov/flu/weekly/nchs.htm")

  PREFIX <- "https://www.cdc.gov"

  xml2::xml_find_all(pg, ".//select[@id='State']/option[contains(@value, 'csv') and
                                                        contains(@value, 'State_')]") %>%
    xml2::xml_attr("value") %>%
    sprintf("%s%s", PREFIX, .) -> targets

  pb <- dplyr::progress_estimated(length(targets))
  purrr::map_df(targets, function(x) {
    pb$tick()$print()
    suppressMessages(readr::read_csv(URLencode(x), col_types="ciidii"))
  }) -> influenza_mortality_by_state

  # scrape (ugh) web page to get data file links for regional mortality data

  xml2::xml_find_all(pg, ".//select[@id='Regional Data']/
                             option[contains(@value, 'csv') and
                                    not(contains(@value, 'Week_'))]") %>%
    xml2::xml_attr("value") %>%
    sprintf("%s%s", PREFIX, .) -> targets

  pb <- dplyr::progress_estimated(length(targets))
  purrr::map_df(targets, function(x) {
    pb$tick()$print()
    suppressMessages(read_csv(URLencode(x), col_types="ciidii"))
  }) -> influenza_mortality_by_region

  # scrape (ugh) web page to get data file links for weekly mortality data

  xml2::xml_find_all(pg, ".//select[@id='Regional Data']/
                             option[contains(@value, 'csv') and
                                    contains(@value, 'Week_')]") %>%
    xml2::xml_attr("value") %>%
    sprintf("%s%s", PREFIX, .) -> targets

  pb <- dplyr::progress_estimated(length(targets))
  purrr::map_df(targets, function(x) {
    pb$tick()$print()
    suppressMessages(read_csv(URLencode(x), col_types="ciidii"))
  }) -> influenza_mortality_by_week

  # if return it all

  list(
    by_state = influenza_mortality_by_state,
    by_region = influenza_mortality_by_region,
    by_week = influenza_mortality_by_week
  ) -> out

  class(out) <- c("cfv_mortality", class(out))

  out

}