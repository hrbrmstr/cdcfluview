=======
#' Retrieve 'U.S'.' Flu Season Data from the 'CDC' 'FluView' Portal
#'
#' The U.S. Centers for Disease Control (CDC) maintains a portal
#' <http://gis.cdc.gov/grasp/fluview/fluportaldashboard.html> for
#' accessing state, regional and national influenza statistics as well as
#' Mortality Surveillance Data. The Flash interface makes it difficult and
#' time-consuming to select and retrieve influenza data. This package
#' provides functions to access the data provided by the portal's underlying API.
#'
#' @md
#' @name cdcfluview
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import httr
#' @importFrom tools file_path_sans_ext
#' @importFrom dplyr left_join bind_rows mutate filter %>%
#' @importFrom jsonlite fromJSON
#' @importFrom stats setNames
#' @importFrom sf st_read
#' @importFrom utils read.csv unzip
NULL
