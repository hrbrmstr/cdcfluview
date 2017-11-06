# THIS IS NOT EXPORTED FROM MMWRweek but I need it
# Find start date for a calendar year
#
# Finds the state date given a numeric calendar year
# @author Jarad Niemi \email{niemi@@iastate.edu}
.start_date = function(year) {
  # Finds start state for this calendar year
  jan1 = as.Date(paste(year, '-01-01', sep=''))
  wday = as.numeric(MMWRweekday(jan1))
  jan1 - (wday-1) + 7*(wday>4)
}

# I discovered why 1962!: https://www.cdc.gov/mmwr/preview/mmwrhtml/su6004a9.htm
.tmp <- lapply(1962:2050, .start_date)

mapply(function(.x, .y) {
  data_frame(
    wk_start = seq(.tmp[[.x]], .tmp[[.y]], "1 week"),
    wk_end = wk_start + 6,
    year_wk_num = 1:length(wk_start)
  ) -> tmp
  tmp[-nrow(tmp),]
}, 1:(length(.tmp)-1), 2:length(.tmp), SIMPLIFY=FALSE) -> mmwrid_map

mmwrid_map <- Reduce(rbind.data.frame, mmwrid_map)
mmwrid_map$mmwrid <- 1:nrow(mmwrid_map)

#' @title MMWR ID to Calendar Mappings
#' @name mmwrid_map
#' @export
NULL
