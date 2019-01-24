## Test environments

* local OS X install, R 3.5.2
* local Ubuntu 16.04 R 3.5.2
* ubuntu 16.04 (on travis-ci), R current/devel
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a maintenance update.

## Reverse dependencies

None

---

The CDC removed 2 old API endpoints so those functions have been removed.

There was a bug in the computation of "start week" that resulted in 
the "ISO" day being used vs the MMWR/"epi" day being used. This 
has also been fixed.

Only some examples run on CRAN due to their time consuming nature and the need
to make external network API calls. Monthly tests are performed on Travis-CI 
<https://travis-ci.org/hrbrmstr/cdcfluview> and the package itself has 88%
code coverage during tests <https://codecov.io/github/hrbrmstr/cdcfluview?branch=master>.
All package functions are also evaluated on each new generation of the README.