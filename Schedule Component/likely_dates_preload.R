#Preload some datasets to save downloading time for impending game days

day0 <- as.character(as.Date(with_tz(Sys.time(),tzone = "EST")))
day1 <- as.character(as.Date(with_tz(Sys.time(),tzone = "EST"))+1)
day2 <- as.character(as.Date(with_tz(Sys.time(),tzone = "EST"))+2)
day3 <- as.character(as.Date(with_tz(Sys.time(),tzone = "EST"))+3)
day4 <- as.character(as.Date(with_tz(Sys.time(),tzone = "EST"))+4)

day0_data <- expected_values(schedule_builder(day0))
day1_data <- expected_values(schedule_builder(day1))
day2_data <- expected_values(schedule_builder(day2))
day3_data <- expected_values(schedule_builder(day3))
day4_data <- expected_values(schedule_builder(day4))

day0_data_excel <- expected_excel_format(day0_data)
day1_data_excel <- expected_excel_format(day1_data)
day2_data_excel <- expected_excel_format(day2_data)
day3_data_excel <- expected_excel_format(day3_data)
day4_data_excel <- expected_excel_format(day4_data)



