# cdcfluview 0.7.0

* The CDC changed most of their API endpoints to support a new HTML interface.
  There are many breaking changes but also many new data endpoints.

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