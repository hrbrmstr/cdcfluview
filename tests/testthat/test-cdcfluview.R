context("basic functionality")
test_that("we can do something", {

  expect_that(dim(get_flu_data("hhs", years=2015)), equals(c(520L, 15L)))

  expect_that(dim(get_state_data(2008)), equals(c(2494L, 8L)))

  invisible(get_flu_data())

  invisible(get_flu_data(data_source="all"))

  invisible(get_weekly_flu_report())

})

test_that("these are potentially time-consuming calls", {

  skip_on_cran()

  invisible(get_mortality_surveillance_data())

})