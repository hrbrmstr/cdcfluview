context("basic functionality")
test_that("we can do something", {

  expect_that(dim(get_flu_data("hhs", years=2015)), equals(c(520L, 15L)))

  expect_that(dim(get_state_data(2008)), equals(c(2494L, 8L)))

})
