#test 1a: that there is a "start" variable in the dataset, else error
test_that("start variable exists", {
  expect_error(add_duration(.dataset=clean_data, duration_var_name="duration", start = "ddd",
                            end="end", uuid="X_uuid"),
               regexp ="data needs to have a column start for this function work")

})
#test 1b: that there is a  "end" variable in the dataset, else error
test_that("end variable exists", {
  expect_error(add_duration(.dataset=clean_data, duration_var_name="duration", start = "X.U.FEFF.start",
                            end="end_xx", uuid="X_uuid"),
               regexp ="data needs to have a column end for this function work")

})
#test 2: that the duration_var_name column does not exist already
test_that("variable duration does not exist", {
  expect_error(add_duration(.dataset=clean_data, duration_var_name="X_status", start = "X.U.FEFF.start",
                            end="end", uuid="X_uuid"),
               regexp ="There is already a variable called duration_var_name in your dataset, please input another duration_var_name")

})

#test 3: that there a start and an end time for each survey, if there isnt, throw a warning, counting the number of issues
test_that("no missing values in start and end variables", {
  test_data <- clean_data
  test_data[1,"X.U.FEFF.start"] <- NA
  expect_warning(add_duration(.dataset=test_data, duration_var_name="new_duration", start = "X.U.FEFF.start",
                              end="end", uuid="X_uuid"),
               regexp ="There are some observations for which either start or end is missing. The duration will not be computed for these")

})

#test 4: the function does not run if the data is not in KOBO format
test_that("function does not run if the data is not in KOBO format", {
  test_data <- clean_data
  test_data[1,"X.U.FEFF.start"] <- "111111111"
  expect_error(add_duration(.dataset=test_data, duration_var_name="new_duration", start = "X.U.FEFF.start",
                              end="end", uuid="X_uuid"),
                 regexp ="The dates are not in the correct format, the duration cannot be computed")

})


# #test that both start and end have the correct format (date and time), else STOP ////[later]if not, the variable should be made in the correct format
# test_that("start and end are in the correct format", {
#   expect_warning(make_duration(.dataset = data),
#                  regexp ="Start and end are not in the format DD/MM/YY Hour")
#
# })
#


#test that the new variable "duration" has correct value (difference end-start)
test_that("duration is correct", {
  #test data
  test_data <- data.frame(`X.U.FEFF.start` = c("2021-07-13T11:25:49.543+03:00", "2021-07-13T12:36:16.316+03:00",
                                               "2021-07-13T10:21:10.337+03:00", "2021-07-13T10:54:07.394+03:00", "2021-07-13T11:18:45.521+03:00"),
                          end = c("2021-07-13T12:02:39.269+03:00", "2021-07-13T13:20:17.815+03:00",
                                  "2021-07-13T10:53:42.662+03:00", "2021-07-13T11:28:58.295+03:00", "2021-07-13T11:55:24.366+03:00"),
                          uuid = 1:5
                          )
  #expected output
  expected_output <- data.frame(`X.U.FEFF.start` = c("2021-07-13T11:25:49.543+03:00", "2021-07-13T12:36:16.316+03:00",
                                                     "2021-07-13T10:21:10.337+03:00", "2021-07-13T10:54:07.394+03:00", "2021-07-13T11:18:45.521+03:00"),
                                end = c("2021-07-13T12:02:39.269+03:00", "2021-07-13T13:20:17.815+03:00",
                                        "2021-07-13T10:53:42.662+03:00", "2021-07-13T11:28:58.295+03:00", "2021-07-13T11:55:24.366+03:00"),
                                start_date = rep("2021-07-13",5),
                                start_time = c("685.82", "756.27", "621.17", "654.12", "678.75"),
                                end_date = rep("2021-07-13", 5),
                                duration = as.numeric(c("36.83", "44.01", "32.53", "34.85", "36.65")
                                                      ))
  #function
  actual_output <- add_duration(.dataset=test_data, duration_var_name="duration", start = "X.U.FEFF.start",
                                  end="end", uuid="X_uuid") %>%
    select("X.U.FEFF.start","end",  "start_date","start_time", "end_date", "duration") %>%
    mutate( start_time = as.character(start_time))

  #test
  expect_equal(actual_output ,
               expected_output)
  })


#test that the new variable "duration" has correct value when the date also changes
test_that("duration is correct", {
  #test data
  test_data <- data.frame(`X.U.FEFF.start` = c("2021-07-13T11:25:49.543+03:00", "2021-07-13T12:36:16.316+03:00",
                                               "2021-07-13T10:21:10.337+03:00", "2021-07-13T10:54:07.394+03:00", "2021-07-13T11:18:45.521+03:00"),
                          end = c("2021-07-14T12:02:39.269+03:00", "2021-07-13T13:20:17.815+03:00", #changed first date to 14th instead of 13th
                                  "2021-07-13T10:53:42.662+03:00", "2021-07-13T11:28:58.295+03:00", "2021-07-13T11:55:24.366+03:00"),
                          uuid = 1:5
  )
  #expected output
  expected_output <- data.frame(`X.U.FEFF.start` = c("2021-07-13T11:25:49.543+03:00", "2021-07-13T12:36:16.316+03:00",
                                                     "2021-07-13T10:21:10.337+03:00", "2021-07-13T10:54:07.394+03:00", "2021-07-13T11:18:45.521+03:00"),
                                end = c("2021-07-14T12:02:39.269+03:00", "2021-07-13T13:20:17.815+03:00", #changed first date to 14th instead of 13th
                                        "2021-07-13T10:53:42.662+03:00", "2021-07-13T11:28:58.295+03:00", "2021-07-13T11:55:24.366+03:00"),
                                start_date = rep("2021-07-13",5),
                                start_time = c("685.82", "756.27", "621.17", "654.12", "678.75"),
                                end_date = c("2021-07-14" ,rep("2021-07-13", 4)),
                                duration = as.numeric(c("1476.83", "44.01", "32.53", "34.85", "36.65") #change first duration to 24*60 + old duration
                                ))
  #function
  actual_output <- add_duration(.dataset=test_data, duration_var_name="duration", start = "X.U.FEFF.start",
                                end="end", uuid="X_uuid") %>%
    select("X.U.FEFF.start","end",  "start_date","start_time", "end_date", "duration") %>%
    mutate( start_time = as.character(start_time))

  #test
  expect_equal(actual_output ,
               expected_output)
})

