context("new API functionality")

test_that("New API works", {

  skip_on_cran()

  expect_that(age_group_distribution(years=2017), is_a("data.frame"))

  expect_that(geographic_spread(years=2017), is_a("data.frame"))

  expect_that(state_data_providers(), is_a("data.frame"))

  expect_that(hospitalizations("flusurv", years=2017), is_a("data.frame"))
  expect_that(hospitalizations("eip", years=2017), is_a("data.frame"))
  expect_that(hospitalizations("eip", "Colorado", years=2017), is_a("data.frame"))
  expect_that(hospitalizations("ihsp", years=2017), is_a("data.frame"))
  expect_that(hospitalizations("ihsp", "Oklahoma", years=2017), is_a("data.frame"))

  expect_that(ilinet("national", years=2017), is_a("data.frame"))
  expect_that(ilinet("hhs", years=2017), is_a("data.frame"))
  expect_that(ilinet("census", years=2017), is_a("data.frame"))
  expect_that(ilinet("state", years=2017), is_a("data.frame"))

  expect_that(ili_weekly_activity_indicators(2017), is_a("data.frame"))

  expect_that(pi_mortality("national", years=2017), is_a("data.frame"))
  expect_that(pi_mortality("state", years=2017), is_a("data.frame"))
  expect_that(pi_mortality("region", years=2017), is_a("data.frame"))

  expect_that(surveillance_areas(), is_a("data.frame"))

  expect_that(who_nrevss("national", years=2017), is_a("list"))
  expect_that(who_nrevss("hhs", years=2017), is_a("list"))
  expect_that(who_nrevss("census", years=2017), is_a("list"))
  expect_that(who_nrevss("state", years=2017), is_a("list"))

  expect_that(cdc_basemap("national"), is_a("sf"))
  expect_that(cdc_basemap("hhs"), is_a("sf"))
  expect_that(cdc_basemap("census"), is_a("sf"))
  expect_that(cdc_basemap("states"), is_a("sf"))
  expect_that(cdc_basemap("spread"), is_a("sf"))
  expect_that(cdc_basemap("surv"), is_a("sf"))

  m1 <- mmwr_week(as.Date("2017-03-01"))
  m2 <- mmwr_weekday(as.Date("2017-03-01"))

  expect_equal(m1$mmwr_year[1], 2017)
  expect_equal(m1$mmwr_week[1], 9)
  expect_equal(m1$mmwr_day[1], 4)

  expect_that(m2, is_a("factor"))
  expect_equal(as.character(m2), "Wednesday")

  expect_equal(mmwr_week_to_date(2016,10,3), structure(16868, class = "Date"))

})


context("old API functionality")

test_that("Old API works", {

  skip_on_cran()

  expect_that(dim(get_flu_data("hhs", years=2015)), equals(c(520L, 15L)))

  expect_that(dim(get_state_data(2008)), equals(c(2494L, 8L)))

  invisible(get_flu_data())

  invisible(get_hosp_data())

  invisible(get_flu_data(data_source="all"))

  invisible(get_weekly_flu_report())

})

test_that("these are potentially time-consuming calls", {

  skip_on_cran()

  invisible(get_mortality_surveillance_data())

})