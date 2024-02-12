#Download of Excel version of scheduled games and expected values

library(openxlsx)
library(shinydashboard)


excel_download <- box(
  background = "light-blue",
  width = 12,
  fluidRow(
    column(12,
           style="text-align: justify;",
           "Please note game times are currently only EST.  A nice layout is coming, but for now this will allow you to download the schedule in a usable excel format.  If you are downloading a day very far out it may take a few seconds to open the download dialog box as the data is only pre-loaded 4 days out.")
  ),
  fluidRow(id = "excel_dl_button",
    column(8,
           dateInput(
             "selected_date",label = "Date Input",
             value = as.Date(with_tz(Sys.time(),tzone = "EST")),
             min = first_day_of_games,
             max = last_day_of_games
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


