library(lubridate)

#Current season year (year when the championship will happen)
champ_year <- 2027
exclude_dates <- c("2026-12-24","2026-12-25","2026-12-26")
previous_year_first_day_of_games <- "2025-11-03"
first_day_of_games <- "2026-11-01"
last_year_last_day_of_games <- "2026-04-06"
last_day_of_games <- "2027-04-05"


if(((as.Date(with_tz(Sys.time(),tzone = "America/Toronto"), tz = "America/Toronto") > last_year_last_day_of_games)
   & (as.Date(with_tz(Sys.time(),tzone = "America/Toronto"), tz = "America/Toronto") < paste0((champ_year-1),"-10-20")))
   | (as.Date(with_tz(Sys.time(),tzone = "America/Toronto"), tz = "America/Toronto") > last_day_of_games)){
  preseason <- FALSE
  offseason <- TRUE
} else if((as.Date(with_tz(Sys.time(),tzone = "America/Toronto"), tz = "America/Toronto") >= paste0((champ_year-1),"-10-20"))
          & (as.Date(with_tz(Sys.time(),tzone = "America/Toronto"), tz = "America/Toronto") < first_day_of_games)){
  preseason <- TRUE
  offseason <- FALSE
} else if((as.Date(with_tz(Sys.time(),tzone = "America/Toronto"), tz = "America/Toronto") >= first_day_of_games)
          & (as.Date(with_tz(Sys.time(),tzone = "America/Toronto"), tz = "America/Toronto") <= last_day_of_games)){
  preseason <- FALSE
  offseason <- FALSE
}

if((as.Date(with_tz(Sys.time(),tzone = "America/Toronto"), tz = "America/Toronto") > last_year_last_day_of_games)
   & (as.Date(with_tz(Sys.time(),tzone = "America/Toronto"), tz = "America/Toronto") < paste0((champ_year-1),"-10-20"))){
  champ_year <- champ_year-1
}
