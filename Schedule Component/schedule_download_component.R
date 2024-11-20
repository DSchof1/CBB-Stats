#Download of Excel version of scheduled games and expected values

library(openxlsx)
library(shinydashboard)
source("Data/year.R")


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
             #value = as.Date(with_tz("2024-04-08",tzone = "America/Toronto")),
             value = as.Date(with_tz(Sys.time(),tzone = "America/Toronto")),
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


