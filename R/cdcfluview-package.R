#' Retrieve Flu Season Data from the CDC FluView Portal
#'
#' The U.S. Centers for Disease Control (CDC) maintains a portal
#' \code{https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html} for
#' accessing state, regional and national influenza statistics as well as
#' Mortality Surveillance Data. The Flash interface makes it difficult
#' and time-consuming to select and retrieve influenza data. This package
#' provides functions to access the data provided by portal's underlying API.
#'
#' @name cdcfluview
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import httr xml2 dplyr utils V8
#' @importFrom purrr map map_df map_chr map_lgl discard keep
#' @importFrom readr read_csv type_convert
#' @importFrom jsonlite fromJSON
NULL
