context("basic functionality")
test_that("we can do something", {

  skip_on_cran()

  expect_that(age_group_distribution(), is_a("data.frame"))

  expect_that(geographic_spread(), is_a("data.frame"))

  expect_that(state_data_providers(), is_a("data.frame"))

  expect_that(hospitalizations("flusurv"), is_a("data.frame"))
  expect_that(hospitalizations("eip"), is_a("data.frame"))
  expect_that(hospitalizations("eip", "Colorado"), is_a("data.frame"))
  expect_that(hospitalizations("ihsp"), is_a("data.frame"))
  expect_that(hospitalizations("ihsp", "Oklahoma"), is_a("data.frame"))

  expect_that(ilinet("national"), is_a("data.frame"))
  expect_that(ilinet("hhs"), is_a("data.frame"))
  expect_that(ilinet("census"), is_a("data.frame"))
  expect_that(ilinet("state"), is_a("data.frame"))

  expect_that(ili_weekly_activity_indicators(2017), is_a("data.frame"))

  expect_that(pi_mortality("national"), is_a("data.frame"))
  expect_that(pi_mortality("state"), is_a("data.frame"))
  expect_that(pi_mortality("region"), is_a("data.frame"))

  expect_that(surveillance_areas(), is_a("data.frame"))

  expect_that(who_nrevss("national"), is_a("list"))
  expect_that(who_nrevss("hhs"), is_a("list"))
  expect_that(who_nrevss("census"), is_a("list"))
  expect_that(who_nrevss("state"), is_a("list"))

  expect_that(cdc_basemap("national"), is_a("sf"))
  expect_that(cdc_basemap("hhs"), is_a("sf"))
  expect_that(cdc_basemap("census"), is_a("sf"))
  expect_that(cdc_basemap("states"), is_a("sf"))
  expect_that(cdc_basemap("spread"), is_a("sf"))
  expect_that(cdc_basemap("surv"), is_a("sf"))

  expect_equal(mmwr_week(Sys.Date()),
               structure(list(mmwr_year = 2017, mmwr_week = 45, mmwr_day = 2),
                         .Names = c("mmwr_year", "mmwr_week", "mmwr_day"),
                         row.names = c(NA, -1L),
                         class = c("tbl_df", "tbl", "data.frame"))
  )

  expect_equal(mmwr_weekday(Sys.Date()),
               structure(2L, .Label = c("Sunday", "Monday", "Tuesday", "Wednesday",
                                        "Thursday", "Friday", "Saturday"),
                         class = "factor"))

  expect_equal(mmwr_week_to_date(2016,10,3), structure(16868, class = "Date"))

})
