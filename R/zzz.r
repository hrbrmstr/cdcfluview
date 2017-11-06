# this is only used during active development phases before/after CRAN releases

.onAttach <- function(...) { # nocov start

  if (!interactive()) return()

  packageStartupMessage(paste0("cdcfluview is under *active* development. ",
                               "There are *MASSIVE* breaking changes*. ",
                               "See https://github.com/hrbrmstr/cdcfluview for info/news."))

} # nocov end
