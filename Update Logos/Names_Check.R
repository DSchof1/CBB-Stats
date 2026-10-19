library(jsonlite)
library(httr2)
library(readxl)
library(dplyr)
library(rvest)

Logos <- read_excel("Data/Logos.xlsx")


# Check for new D1 teams
new_teams <- function(year) {
  
  url <- paste0(
    "https://barttorvik.com/",
    year,
    "_team_results.json"
  )
  
  response <- request(url) |>
    req_user_agent("curl/8.0") |>
    req_perform()
  
  bart_data <- fromJSON(
    resp_body_string(response),
    simplifyVector = FALSE
  )
  
  # TEAM is the second field in Barttorvik's data
  team_names <- vapply(
    bart_data,
    function(x) as.character(x[[2]]),
    character(1)
  )
  
  new_team_names <- team_names[
    !(team_names %in% Logos$TEAM)
  ]
  
  return(new_team_names)
}


# Run both checks
updates <- function(year) {
  
  year <- as.integer(year)
  
  cat("The following teams have been added to D1 and will require logo info:\n\n")
  
  new_team_names <- new_teams(year)
  
  if (length(new_team_names) > 0) {
    cat(paste(new_team_names, collapse = "\n"), "\n")
  }

  
  invisible(new_team_names)
}


#updates(2027)
