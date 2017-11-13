#' Retrieves influenza hospitalization statistics from the CDC (deprecated)
#'
#' Uses the data source from the
#' \href{https://gis.cdc.gov/GRASP/Fluview/FluHospRates.html}{CDC FluView}
#' and provides influenza hospitalization reporting data as a data frame.
#'
#' @param area one of "\code{flusurvnet}", "\code{eip}", "\code{ihsp}", or two
#'        digit state abbreviation for an individual site. Exceptions are
#'        New York - Albany ("\code{nya}") and New York - Rochester
#'        ("\code{nyr}")
#' @param age_group a vector of age groups to pull data for. Possible values are:
#'        "\code{overall}", "\code{0-4y}", "\code{5-17y}, "\code{18-49y},
#'        "\code{50-64y}, "\code{65+y}".
#' @param years a vector of years to retrieve data for (i.e. \code{2014} for CDC
#'        flu season 2014-2015). Default value is the current year and all
#'        \code{years} values should be >= \code{2009}
#' @return A single \code{data.frame}.
#' @note There is often a noticeable delay when making the API request to the CDC.
#'       This is not due to a large download size, but the time it takes for their
#'       servers to crunch the data. Wrap the function call in \code{httr::with_verbose}
#'       if you would like to see what's going on.
#' @export
#' @examples \dontrun{
#' # All of FluSurv-NET, 50-64 years old, 2010/11-2014/15 flu seasons
#' flu <- get_hosp_data("flusurvnet", "50-64y", years=2010:2014)
#' }
get_hosp_data <- function(area="flusurvnet", age_group="overall",
                          years=as.numeric(format(Sys.Date(), "%Y")) - 1) {

  message(
    paste0(
      c("This function has been deprecated and will be removed in future releases.",
        "Use hospitalizations() instead."),
      collapse="\n"
    )
  )

  area <- tolower(area)
  age_group <- tolower(age_group)

  if (!(area %in% c("flusurvnet", "eip", "ihsp", "ca", "co", "ct", "ga", "md",
                    "mn", "nm", "nya", "nyr", "or", "tn", "id", "ia", "mi",
                    "oh", "ok", "ri", "sd", "ut")))
    stop("Error: area must be one of flusurvnet, eip, ihsp, or a valid state abbreviation")

  if (length(area) != 1)
    stop("Error: can only select one area")

  if (!all(age_group %in% c("overall", "0-4y", "5-17y", "18-49y",
                            "50-64y", "65+y")))
    stop("Error: invalid age group specified")

  if (any(years < 2009))
    stop("Error: years should be >= 2009")

  # Match names of age groups to numbers for API
  age_match <- data.frame(age_group = c("overall", "0-4y", "5-17y",
                                        "18-49y", "50-64y", "65+y"),
                          code = c(6, 1, 2, 3, 4, 5))

  age_group_num <- age_match$code[age_match$age_group %in% age_group]


  # format the input parameters to fit the CDC API

  years <- years - 1960

  area_match <- data.frame(
    area = c("flusurvnet", "eip", "ca", "co", "ct",
             "ga", "md", "mn", "nm", "nya", "nyr", "or",
             "tn", "ihsp", "id", "ia", "mi", "oh", "ok",
             "ri", "sd", "ut"),
    catch = c(22, 22, 1, 2, 3, 4, 7, 9, 11, 13, 14, 17,
              20, 22, 6, 5, 8, 15, 16, 18, 19, 21),
    network = c(1, rep(2, 12), rep(3, 9)),
    stringsAsFactors=FALSE
  )

  # Format years
  year_list <- lapply(seq_along(years),
                      function(x) list(ID = years[x]))

  # Format age group
  age_list <- lapply(seq_along(age_group_num),
                     function(x) list(ID = age_group_num[x]))

  params <- list(AppVersion = "Public",
                 agegroups = age_list,
                 catchmentid = area_match$catch[area_match$area == area],
                 networkid = area_match$network[area_match$area == area],
                 seasons = year_list)

  out_file <- tempfile(fileext=".json")

  # CDC API returns a ZIP file so we grab, save & expand it to then read in CSVs

  tmp <- httr::POST("https://gis.cdc.gov/GRASP/Flu3/PostPhase03DownloadData",
                    body = params,
                    encode = "json",
                    httr::write_disk(out_file, overwrite = T))

  httr::stop_for_status(tmp)

  if (!(file.exists(out_file)))
    stop("Error: cannot process downloaded data")

  file <- jsonlite::fromJSON(out_file)[[1]]

  return(file)

}
