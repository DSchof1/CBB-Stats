#Download of Excel version of scheduled games and expected values

library(openxlsx)
library(shinydashboard)
source("Data/year.R")


if(offseason == TRUE){
  if(year(as.Date(with_tz(Sys.time(),tzone = "America/Toronto"))) == year(last_year_last_day_of_games)){
    most_recent_excel_dl_day <- last_year_last_day_of_games
  } else if(year(as.Date(with_tz(Sys.time(),tzone = "America/Toronto"))) == year(last_day_of_games)){
    most_recent_excel_dl_day <- last_day_of_games
  }
} else if(preseason == TRUE){
  most_recent_excel_dl_day <- first_day_of_games
} else{
  most_recent_excel_dl_day <- as.Date(with_tz(Sys.time(),tzone = "America/Toronto"))
}


if(offseason == TRUE){
  if((year(as.Date(with_tz(Sys.time(),tzone = "America/Toronto")))-1) == year(previous_year_first_day_of_games)){
    min_calendar_date <- previous_year_first_day_of_games
  } else if((year(as.Date(with_tz(Sys.time(),tzone = "America/Toronto")))-1) == year(first_day_of_games)){
    min_calendar_date <- first_day_of_games
  }
} else{
  min_calendar_date <- first_day_of_games
}


if(offseason == TRUE){
  if(year(as.Date(with_tz(Sys.time(),tzone = "America/Toronto"))) == year(last_year_last_day_of_games)){
    max_calendar_date <- last_year_last_day_of_games
  } else if(year(as.Date(with_tz(Sys.time(),tzone = "America/Toronto"))) == year(last_day_of_games)){
    max_calendar_date <- last_day_of_games
  }
} else{
  max_calendar_date <- last_day_of_games
}


excel_download <- box(
  background = "light-blue",
  width = 12,
  fluidRow(
    column(12,
           style="text-align: justify;",
           "Please note game times are currently only in EST.  If you are downloading a day very far out it may take a few seconds to open the download dialog box as the data is only pre-loaded 4 days out.")
  ),
  fluidRow(id = "excel_dl_button",
    column(8,
           dateInput(
             "selected_date",label = "Select Date",
             value = most_recent_excel_dl_day,
             min = min_calendar_date,
             max = max_calendar_date,
             datesdisabled = exclude_dates
             )
           ),
    column(4,
           downloadButton(
             outputId = "expected_excel_dl",
             label = "Download"
             )
           )
    )
)


