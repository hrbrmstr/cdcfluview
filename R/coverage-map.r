#' Retrieve CDC U.S. Basemaps
#'
#' The CDC FluView application uses a composite basemaps of coverage areas
#' within the United States that elides and scales Alaska, Hawaii,
#' Puerto Rico & the Virgin Islands and some further provide elided and scaled
#' breakouts for New York City and the District of Columbia.\cr
#' \cr
#' This function retrieves the given shapefile, projects to EPSG:5069 and
#' returns it as an `sf` (simple features) object.
#'
#' @md
#' @export
#' @param basemap select the CDC basemap. One of:
#' - "`national`": outline of the U.S. + AK, HI, PR + VI
#' - "`hhs`": outline of the U.S. + HHS Region Outlines + AK, HI, PR + VI
#' - "`census`": outline of the U.S. + Census Region Outlines + AK, HI, PR + VI
#' - "`states`": outline of the U.S. + State Outlines + AK, HI, PR + VI
#' - "`spread`": outline of the U.S. + State Outlines + AK, HI, PR + VI & Guam
#' - "`surv`": outline of the U.S. + State Outlines + AK, HI, PR + VI
#' @note These are just the basemaps. You need to pair it with the data you wish to visualize.
#' @examples \dontrun{
#' plot(cdc_basemap("national"))
#' }
cdc_basemap <- function(basemap = c("national", "hhs", "census", "states", "spread", "surv")) {

  switch(
    basemap,
    national = .national_outline,
    hhs = .hhs_subregions_basemap,
    census = .census_divisions_basemap,
    states = .states_basemap,
    spread = .spread_basemap,
    surv = .surv_basemap
  ) -> selected_map

  xsf <- sf::st_read(selected_map, quiet=TRUE, stringsAsFactors=FALSE)
  sf::st_crs(xsf) <- 4326
  sf::st_transform(xsf, 5069)

}
