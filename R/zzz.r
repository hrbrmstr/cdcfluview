.onAttach <- function(...) { # nocov start

  if (!interactive()) return()

  if (sample(c(TRUE, FALSE), 1, prob = c(0.1, 0.9))) {
    packageStartupMessage(paste0("There are numerous changes & deprecations. ",
                                 "See https://github.com/hrbrmstr/cdcfluview for info/news."))
  }

} # nocov end
