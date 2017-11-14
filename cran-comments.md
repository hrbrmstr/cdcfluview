## Test environments

* local OS X install, R 3.4.2
* local Ubuntu 16.04 R 3.4.1
* ubuntu 14.04 (on travis-ci), R old/current/devel
* win-builder (devel and release)
* rhub Windows (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a maintenance update.

## Reverse dependencies

None

---

The CDC changed most of their API endpoints to support a new HTML interface and 
re-jiggered the back-end API. Craig McGowan updated the old cdcfluview API function
to account for the changes. However, the new API endpoints provided additional
data features and it seemed to make sense to revamp the package to fit more in line
with the way the APIs were structured. Legacy cdcfluview functions have been deprecated
and will display deprecation messages when run. The new cdcfluview package API
changes a few things about how you work with the data but the README and examples
show how to work with it. 

Only some examples run on CRAN due to their time consuming nature and the need
to make external calls. Weekly tests are performed on Travis-CI 
<https://travis-ci.org/hrbrmstr/cdcfluview> and the package itself has 91%
code coverage during tests <https://codecov.io/github/hrbrmstr/cdcfluview?branch=master>.
All package functions are also evaluated on each new generation of the README.