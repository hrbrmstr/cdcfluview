## Test environments
* local OS X install, R 3.3.2 & R-devel
* ubuntu 12.04 (on travis-ci), R 3.3.2, R-oldrel and R-devel
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 notes

---

This is a bug-fix release.

The CDC changed over to using https URLs which broke the core function.

Their state API also changed from returning a CSV file to a JSON direct response.

Tests have been added as well.