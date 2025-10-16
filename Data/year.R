library(lubridate)

#Current season year (year when the championship will happen)
champ_year <- 2026
exclude_dates <- c("2025-12-24","2025-12-25","2025-12-26")
first_day_of_games <- "2025-11-03"
previous_year_first_day_of_games <- "2024-11-04"
last_day_of_games <- "2026-04-06"
last_year_last_day_of_games <- "2025-04-07"

if(((as.Date(with_tz(Sys.time(),tzone = "EST")) > last_year_last_day_of_games)
   & (as.Date(with_tz(Sys.time(),tzone = "EST")) < paste0((champ_year-1),"-10-20")))
   | (as.Date(with_tz(Sys.time(),tzone = "EST")) > last_day_of_games)){
  preseason <- FALSE
  offseason <- TRUE
} else if((as.Date(with_tz(Sys.time(),tzone = "EST")) >= paste0((champ_year-1),"-10-20"))
          & (as.Date(with_tz(Sys.time(),tzone = "EST")) < first_day_of_games)){
  preseason <- TRUE
  offseason <- FALSE
} else if((as.Date(with_tz(Sys.time(),tzone = "EST")) >= first_day_of_games)
          & (as.Date(with_tz(Sys.time(),tzone = "EST")) <= last_day_of_games)){
  preseason <- FALSE
  offseason <- FALSE
}

if((as.Date(with_tz(Sys.time(),tzone = "EST")) > last_year_last_day_of_games)
   & (as.Date(with_tz(Sys.time(),tzone = "EST")) < paste0((champ_year-1),"-10-20"))){
  champ_year <- champ_year-1
}
