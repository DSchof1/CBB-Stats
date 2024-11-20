library(jsonlite)
library(tidyverse)
library(readxl)

Logos <- read_excel("Data/Logos.xlsx")

#Idk why but this isn't exhaustive so there is a bit of manual work
espn_team_name_check <- function(){
  team_names_api_call <- fromJSON("https://site.api.espn.com/apis/site/v2/sports/basketball/mens-college-basketball/teams?groups=50&limit=400")
  team_names <- team_names_api_call$sports$leagues[[1]]$teams[[1]]$team$location
  
  espn_names <- list("changed espn names, ESPN's new name:" = team_names[!(team_names %in% Logos$ESPN_name)],
                     "changed or unavailable, Logos$ESPN_name:" = Logos$ESPN_name[!(Logos$ESPN_name %in% team_names)])
  
  return(espn_names)
}

espn_team_name_check()
