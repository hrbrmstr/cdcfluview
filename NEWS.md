# cdcfluview 0.9.4
- the CDC FluView hidden API changed the returned value structure for the
  `age_group_distribution()` function endpoint. There is now a new column
  `incl_wkly_rates_and_strata` in the returned data frame. Fixes #28 and
  CRAN failures.

# cdcfluview 0.9.2

- Underlying hidden API changed (h/t @Ian-McGovern — #25 & CRAN & Travis) for `age_group_distribution()` so
  this has been fixed and the warnings for `dplyr::progress_estimated()` were also fixed.

# cdcfluview 0.9.1

- renamed `pi_mortality` columns regarding the week to `week_*` instead of `wk_*`
  for consistency with `ilinet` (#21).
- fixed CRAN check errors

# cdcfluview 0.9.0

- fix bug in epiweek computation in ilinet() thanks to a bug report by @jturtle (#19)
- included cloc metrics and refreshed README
- 

# cdcfluview 0.7.0

* The CDC changed most of their API endpoints to support a new HTML interface and 
  re-jiggered the back-end API. Craig McGowan updated the old cdcfluview API function
  to account for the changes. However, the new API endpoints provided additional
  data features and it seemed to make sense to revamp the package to fit more in line
  with the way the APIs were structured. Legacy cdcfluview functions have been deprecated
  and will display deprecation messages when run. The new cdcfluview package API
  changes a few things about how you work with the data but the README and examples
  show how to work with it. 

# cdcfluview 0.5.2

* Modified behavior of `get_flu_data()` to actually grab current flu season
  year if a single year was specified and it is the current year and the
  return is a 0 length data frame (fixes #7)
* Added code coverage tests for all API functions.
  
# cdcfluview 0.5.1

* Replaced `http` URLs with `https` as `http` ones no longer work (fixes #6)
* Fixed State data download (CDC changed the hidden API)

# cdcfluview 0.5.0

* Fixed issue with WHO data format change
* Added Mortality Surveillance Data retrieval function
* Switched to readr::read_csv() and since it handles column names
  better this will break your scripts until you use the new
  column names.

# cdcfluview 0.4.0

* First CRAN release
