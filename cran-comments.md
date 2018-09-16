## Test environments

* local OS X install, R 3.5.1
* local Ubuntu 16.04 R 3.5.1
* ubuntu 14.04 (on travis-ci), R old/current/devel
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a maintenance update.

## Reverse dependencies

None

---

The CDC changed their endpoints again and remove support for one of them. The
function had been deprecated in the previous version submitted to CRAN and
had been removed in this version due to the removal from the CDC.

Support for new endpoints has been added along with tests for these new endpoints.

Only some examples run on CRAN due to their time consuming nature and the need
to make external calls. Weekly tests are performed on Travis-CI 
<https://travis-ci.org/hrbrmstr/cdcfluview> and the package itself has 91%
code coverage during tests <https://codecov.io/github/hrbrmstr/cdcfluview?branch=master>.
All package functions are also evaluated on each new generation of the README.