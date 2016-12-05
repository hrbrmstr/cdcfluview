# cscfluview 0.5.1

* Replaced `http` URLs with `https` as `http` ones no longer work (fixes #6)
* Fixed State data download (CDC changed the hidden API)

# cdcfluview 0.5.0

* Fixed issue with WHO data format change
* Added Mortality Surveillance Data retrieval function
* Switched to readr::read_csv() and since it handles column names
  better this will break your scripts until you use the new
  column names.

