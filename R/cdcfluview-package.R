#' Retrieve Flu Season Data from the United States Centers for Disease Control and Prevention ('CDC') 'FluView' Portal
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
#' @import httr MMWRweek xml2 units
#' @importFrom purrr map map_df map_chr map_lgl discard keep
#' @importFrom readr read_csv type_convert
#' @importFrom tools file_path_sans_ext
#' @importFrom tibble tibble
#' @importFrom dplyr left_join bind_rows mutate filter data_frame %>% arrange
#' @importFrom jsonlite fromJSON
#' @importFrom stats setNames
#' @importFrom sf st_read
#' @importFrom utils read.csv unzip URLencode globalVariables
NULL
