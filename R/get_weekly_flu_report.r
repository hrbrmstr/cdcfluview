#' Retrieves (high-level) weekly influenza surveillance report from the CDC
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
#' get_weekly_flu_report()
#' }
get_weekly_flu_report <- function() {

  # grab the report
  doc <- read_xml("https://www.cdc.gov/flu/weekly/flureport.xml")

  # extract the time periods
  periods <- xml_attrs(xml_find_all(doc, "timeperiod"))

  # for each period extract the state information and
  # shove it all into a data frame
  pb <- progress_estimated(length(periods))
  purrr::map_df(periods, function(period) {

    pb$tick()$print()

    tp <- sprintf("//timeperiod[@number='%s' and @year='%s']",
                  period["number"], period["year"])

    weeks <- xml_find_first(doc, tp)
    kids <- xml_children(weeks)

    abbrev <- xml_text(xml_find_all(kids, "abbrev"), TRUE)
    color <- xml_text(xml_find_all(kids, "color"), TRUE)
    label <- xml_text(xml_find_all(kids, "label"), TRUE)

    data_frame(year=period["year"],
               week_number=period["number"],
               state=abbrev,
               color=color,
               label=label,
               subtitle=period["subtitle"])

  }) -> out

  class(out) <- c("cdcweeklyreport", class(out))

  out

}