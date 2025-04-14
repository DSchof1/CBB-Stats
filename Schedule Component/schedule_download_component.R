#Download of Excel version of scheduled games and expected values

library(openxlsx)
library(shinydashboard)
source("Data/year.R")

if(offseason){
  most_recent_excel_dl_day <- as.Date(with_tz(last_day_of_games,tzone = "America/Toronto"))
} else{
  most_recent_excel_dl_day <- as.Date(with_tz(Sys.time(),tzone = "America/Toronto"))
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
             min = first_day_of_games,
             max = last_day_of_games,
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


