library(jsonlite)
library(httr2)
library(tidyverse)
library(readxl)

Logos <- read_excel("Data/Logos.xlsx")

#Idk why but this isn't exhaustive so there is a bit of manual work
#There are a couple that come up as unavailable, but they're totally fine
espn_team_name_check <- function(){
  url <- "https://site.api.espn.com/apis/site/v2/sports/basketball/mens-college-basketball/teams?groups=50&limit=400"
  
  response <- request(url) |>
    req_user_agent("curl/8.0") |>
    req_perform()
  
  team_names_api_call <- fromJSON(resp_body_string(response))
  team_names <- team_names_api_call$sports$leagues[[1]]$teams[[1]]$team$location
  
  espn_names <- list("changed ESPN names, ESPN's new name:" = team_names[!(team_names %in% Logos$ESPN_name)],
                     "changed or unavailable, Logos$ESPN_name:" = Logos$ESPN_name[!(Logos$ESPN_name %in% team_names)])
  
  return(espn_names)
}

espn_team_name_check()
