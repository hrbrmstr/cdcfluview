#' @title HHS Region Table
#' @description This dataset contains the names, numbers, regional offices for-,
#'              and states/territories belonging to the (presently) 10 HHS U.S.
#'              regions in "long" format. It consists of a \code{data.frame}
#'              with the following columns:
#'
#' \itemize{
#'   \item \code{region}: the official HHS region name (e.g. "\code{Region 1}")
#'   \item \code{region_number}: the associated region number
#'   \item \code{regional_office}: the HHS regional office for the entire region
#'   \item \code{state_or_territory}: state or territory belonging to the region
#' }
#'
#' @docType data
#' @keywords datasets
#' @name hhs_regions
#'
#' @references \url{https://www.hhs.gov/about/agencies/iea/regional-offices/index.html}
#' @usage data(hhs_regions)
#' @note Last updated 2015-08-09.
#' @format A data frame with 59 rows and 4 variables
NULL

#' @title Census Region Table
#' @description This dataset contains the states belonging to the (presently) 4
#'              U.S. Census regions in "long" format. It consists of a \code{data.frame}
#'              with the following columns:
#'
#' \itemize{
#'   \item \code{region}: the official Census region name (e.g. "\code{East}")
#'   \item \code{state}: state belonging to the region
#' }
#'
#' @docType data
#' @keywords datasets
#' @name census_regions
#'
#' @references \url{https://www.cdc.gov/std/stats12/images/CensusMap.png}
#' @usage data(census_regions)
#' @note Last updated 2015-08-09.
#' @format A data frame with 51 rows and 2 variables
NULL
