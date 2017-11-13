#' Retrieves state, regional or national influenza statistics from the CDC (deprecated)
#'
#' Uses the data source from the
#' \href{https://gis.cdc.gov/grasp/fluview/fluportaldashboard.html}{CDC FluView}
#' and provides flu reporting data as either a single data frame or a list of
#' data frames (depending on whether either \code{WHO NREVSS} or \code{ILINet}
#' (or both) is chosen.
#'
#' A lookup table between HHS regions and their member states/territories
#' is provided in \code{\link{hhs_regions}}.
#'
#' @param region one of "\code{hhs}", "\code{census}", "\code{national}",
#'        "\code{state}"
#' @param sub_region depends on the \code{region_type}.\cr
#'        For "\code{national}", the \code{sub_region} should be \code{NA}.\cr
#'        For "\code{hhs}", should be a vector between \code{1:10}.\cr
#'        For "\code{census}", should be a vector between \code{1:9}.\cr
#'        For "\code{state}", should be a vector of state/territory names
#'        or "\code{all}".
#' @param data_source either of "\code{who}" (for WHO NREVSS) or "\code{ilinet}"
#'        or "\code{all}" (for both)
#' @param years a vector of years to retrieve data for (i.e. \code{2014} for CDC
#'        flu season 2014-2015). Default value is the current year and all
#'        \code{years} values should be > \code{1997}
#' @return If only a single \code{data_source} is specified, then a single
#'         \code{data.frame} is returned, otherwise a named list with each
#'         \code{data.frame} is returned.
#' @note There is often a noticeable delay when making the API request to the CDC.
#'       This is not due to a large download size, but the time it takes for their
#'       servers to crunch the data. Wrap the function call in \code{httr::with_verbose}
#'       if you would like to see what's going on.
#' @export
#' @examples \dontrun{
#' flu <- get_flu_data("hhs", 1:10, c("who", "ilinet"), years=2000:2014)
#' }
get_flu_data <- function(region="hhs", sub_region=1:10,
                         data_source="ilinet",
                         years=as.numeric(format(Sys.Date(), "%Y"))) {

  message(
    paste0(
      c("This function has been deprecated and will be removed in future releases.",
        "Use either ilinet() or who_nrevss() instead."),
      collapse="\n"
    )
  )

  region <- tolower(region)
  data_source <- tolower(data_source)

  if (!(region %in% c("hhs", "census", "national", "state")))
    stop("Error: region must be one of hhs, census or national")

  if (length(region) != 1)
    stop("Error: can only select one region")

  if (region=="national") sub_region = 0

  if ((region=="hhs") && !all(sub_region %in% 1:10))
    stop("Error: sub_region values must fall between 1:10 when region is 'hhs'")

  if ((region=="census") && !all(sub_region %in% 1:19))
    stop("Error: sub_region values must fall between 1:10 when region is 'census'")

  if (!all(data_source %in% c("who", "ilinet", "all")))
    stop("Error: data_source must be either 'who', 'ilinet', 'all' or c('who', 'ilinet')")

  if (any(years < 1997))
    stop("Error: years should be > 1997")

  # Match names of states to numbers for API
  if (region == "state") {
    sub_region <- tolower(sub_region)

    if (any(sub_region == "all")) {
      sub_region_inpt <- 1:57
    } else {
      state_match <- data.frame(state = tolower(c(sort(c(datasets::state.name,
                                                         "District of Columbia")),
                                                  "American Samoa",
                                                  "Commonwealth of the Northern Mariana Islands",
                                                  "Puerto Rico",
                                                  "Virgin Islands",
                                                  "New York City",
                                                  "Los Angeles")),
                                num = 1:57,
                                stringsAsFactors = F)

      sub_region_inpt <- state_match$num[state_match$state %in% sub_region]

      if (length(sub_region_inpt) == 0)
        stop("Error: no eligible state/territory names provided")
    }
  } else sub_region_inpt <- sub_region

  # format the input parameters to fit the CDC API

  years <- years - 1960

  reg <- as.numeric(c("hhs"=1, "census"=2, "national"=3, "state" = 5)[[region]])

  # Format data source
  if (data_source == "who") {
    data_list <- list(list(ID = 0,
                           Name = "WHO_NREVSS"))
  } else if (data_source == "ilinet") {
    data_list <- list(list(ID = 1,
                           Name = "ILINet"))
  } else data_list <- list(list(ID = 0,
                                Name = "WHO_NREVSS"),
                           list(ID = 1,
                                Name = "ILINet"))

  # Format years
  year_list <- lapply(seq_along(years),
                      function(x) list(ID = years[x],
                                       Name = paste(years[x])))

  # Format sub regions
  sub_reg_list <- lapply(seq_along(sub_region_inpt),
                         function(x) list(ID = sub_region_inpt[x],
                                          Name = paste(sub_region_inpt[x])))

  params <- list(AppVersion = "Public",
                 DatasourceDT = data_list,
                 RegionTypeId = reg,
                 SeasonsDT = year_list,
                 SubRegionsDT = sub_reg_list)

  out_file <- tempfile(fileext=".zip")

  # CDC API returns a ZIP file so we grab, save & expand it to then read in CSVs

  tmp <- httr::POST("https://gis.cdc.gov/grasp/flu2/PostPhase02DataDownload",
                    body = params,
                    encode = "json",
                    httr::write_disk(out_file))

  httr::stop_for_status(tmp)

  if (!(file.exists(out_file)))
    stop("Error: cannot process downloaded data")

  out_dir <- tempdir()

  files <- unzip(out_file, exdir=out_dir, overwrite=TRUE)

  pb <- dplyr::progress_estimated(length(files))
  lapply(files, function(x) {
    pb$tick()$print()
    ct <- ifelse(grepl("who", x, ignore.case=TRUE), 1, 1)
    suppressMessages(readr::read_csv(x, skip=ct))
  }) -> file_list

  names(file_list) <- substr(basename(files), 1, nchar(basename(files)) - 4)

  # If data are missing, X causes numeric columns to be read as character
  lapply(file_list, function(x) {
    # Create list of columns that should be numeric - exclude character columns
    cols <- which(!colnames(x) %in% c("REGION", "REGION TYPE",
                                      "SEASON_DESCRIPTION"))
    suppressWarnings(x[cols] <- purrr::map(x[cols], as.numeric))
    return(x)
  }) -> file_list


  # Depending on the parameters, there could be more than one
  # file returned. When there's only one, return a more usable
  # structure.

  if (length(file_list) == 1) {

    file_list <- file_list[[1]]

    # when no rows, then it's likely the caller specified the
    # current year and the flu season has technically not started yet.
    # so help them out and move the year back and get current flu
    # season data.

    if ((nrow(file_list) == 0) &&
        (length(years)==1) &&
        (years == (as.numeric(format(Sys.Date(), "%Y"))-1960))) {

      message("Adjusting [years] to get current season...")
      return(get_flu_data(region=region, sub_region=sub_region,
                          data_source=data_source, years=years+1960-1))
    } else {
      return(file_list)
    }

  } else {
    return(file_list)
  }

}

