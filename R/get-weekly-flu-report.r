#' Retrieves (high-level) weekly (XML) influenza surveillance report from the CDC
#'
#' The CDC publishes a \href{https://www.cdc.gov/flu/weekly/usmap.htm}{weekly
#' influenza report} detailing high-level flu activity per-state. They also
#' publish a data file (see \code{References}) of historical report readings.
#' This function reads that XML file and produces a long \code{data_frame}
#' with the historical surveillance readings.\cr
#' \cr
#' This function provides similar data to \code{\link{get_state_data}} but without
#' the reporting source metadata and a limit on the historical flu information.
#'
#' @references \url{https://www.cdc.gov/flu/weekly/flureport.xml}
#' @return \code{tbl_df} (also classed with \code{cdcweeklyreport}) with six
#'         columns: \code{year}, \code{week_number}, \code{state}, \code{color},
#'         \code{label}, \code{subtitle}
#' @export
#' @examples \dontrun{
#' wfr <- get_weekly_flu_report()
#' }
get_weekly_flu_report <- function() {

  # grab the report
  doc <- xml2::read_xml("https://www.cdc.gov/flu/weekly/flureport.xml")

  # extract the time periods
  periods <- xml2::xml_attrs(xml2::xml_find_all(doc, "timeperiod"))

  # for each period extract the state information and
  # shove it all into a data frame
  pb <- dplyr::progress_estimated(length(periods))

  suppressWarnings(suppressMessages(
  purrr::map_df(periods, function(period) {

    pb$tick()$print()

    tp <- sprintf("//timeperiod[@number='%s' and @year='%s']",
                  period["number"], period["year"])

    weeks <- xml2::xml_find_first(doc, tp)
    kids <- xml2::xml_children(weeks)

    abbrev <- xml2::xml_text(xml2::xml_find_all(kids, "abbrev"), TRUE)
    color <- xml2::xml_text(xml2::xml_find_all(kids, "color"), TRUE)
    label <- xml2::xml_text(xml2::xml_find_all(kids, "label"), TRUE)

    tibble::tibble(
      year = period["year"],
      week_number = period["number"],
      state = abbrev,
      color = color,
      label = label,
      subtitle = period["subtitle"]
    )

  }) -> out))

  class(out) <- c("cdcweeklyreport", class(out))

  out

}