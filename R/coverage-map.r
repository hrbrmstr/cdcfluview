#' Retrieve CDC U.S. Coverage Map
#'
#' The CDC FluView application uses a composite basemap of coverage areas
#' within the United States that elides and scales Alaska, Hawaii and
#' Puerto Rico and provides elided and scaled breakouts for New York City
#' and the District of Columbia.\cr
#' \cr
#' The basemap provides polygon identifiers by:
#' \cr
#' - `STATE_FIPS`
#' - `STATE_ABBR`
#' - `STATE_NAME`
#' - `HHS_Region`
#' - `FIPSTXT`)
#' \cr
#' This function retrieves the shapefile, projects to EPSG:5069 and
#' returns it as an `sf` (simple features) object.
#'
#' @md
#' @export
#' @examples \dontrun{
#' plot(cdc_coverage_map())
#' }
cdc_coverage_map <- function() {
  xsf <- sf::st_read(.cdc_basemap, quiet=TRUE, stringsAsFactors=FALSE)
  sf::st_crs(xsf) <- 4326
  sf::st_transform(xsf, 5069)
}
