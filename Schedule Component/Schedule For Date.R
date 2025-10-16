library(jsonlite)
library(readxl)
library(lubridate)

Logos <- read_excel("Data/Logos.xlsx")

#Function to build schedule for a given date
#Pass date in the format YYYY-MM-DD
schedule_builder <- function(game_date){
  
  formatted_date <- gsub("-", "", as.character(game_date))
  day_schedule <- data.frame()
  
  if(inherits(try(fromJSON(paste0("https://site.api.espn.com/apis/site/v2/sports/basketball/mens-college-basketball/scoreboard?dates=",formatted_date,"&groups=50&limit=366")),
                  silent = TRUE), "try-error") | 
     is.null(fromJSON(paste0("https://site.api.espn.com/apis/site/v2/sports/basketball/mens-college-basketball/scoreboard?dates=",formatted_date,"&groups=50&limit=366"))$events$competitions)){
    day_schedule <- data.frame(X1=double(), X2=logical(), X3=character(), X4=character(),
                               X5=character(), X6=character(), X7=numeric(),
                               X8=numeric(), X9=character())
    names(day_schedule) <- c("Date","Neutral Site","Away","Home","Away Logo","Home Logo","Away Score",
                             "Home Score","Game Status")
    return(day_schedule)
  }
  else{
    api_call <- fromJSON(paste0("https://site.api.espn.com/apis/site/v2/sports/basketball/mens-college-basketball/scoreboard?dates=",formatted_date,"&groups=50&limit=366"))
    
    #Deal with TBDs
    tbd_list <- api_call[["events"]][["name"]]
    api_call <- api_call$events$competitions[match(tbd_list[!grepl("TBD", tbd_list)], tbd_list)]
    
    if(length(api_call) == 0){
      day_schedule <- data.frame(X1=double(), X2=logical(), X3=character(), X4=character(),
                                 X5=character(), X6=character(), X7=numeric(),
                                 X8=numeric(), X9=character())
      names(day_schedule) <- c("Date","Neutral Site","Away","Home","Away Logo","Home Logo","Away Score",
                               "Home Score","Game Status")
      return(day_schedule)
    }
    
    for(i in 1:length(api_call)){
      vec_to_add <- c(getElement(unlist(api_call[i]), "date"),
                      getElement(unlist(api_call[i]), "neutralSite"),
                      getElement(unlist(api_call[i]), "competitors.team.location2"),
                      getElement(unlist(api_call[i]), "competitors.team.location1"),
                      getElement(unlist(api_call[i]), "competitors.team.logo2"),
                      getElement(unlist(api_call[i]), "competitors.team.logo1"),
                      getElement(unlist(api_call[i]), "competitors.score2"),
                      getElement(unlist(api_call[i]), "competitors.score1"),
                      getElement(unlist(api_call[i]), "status.type.name")
      )
      day_schedule <- rbind(day_schedule,vec_to_add)
    }
    names(day_schedule) <- c("Date","Neutral Site", "Away", "Home", "Away Logo", "Home Logo", "Away Score", "Home Score", "Game Status")
    
    #Remove games that aren't against D1 competition
    day_schedule <- day_schedule[(day_schedule$Away %in% Logos$ESPN_name),]
    day_schedule <- day_schedule[(day_schedule$Home %in% Logos$ESPN_name),]
    
    #Change team names to Barttorvik names for easier time later applying expected values
    day_schedule$Away <- Logos[match(day_schedule$Away,Logos$ESPN_name),]$TEAM
    day_schedule$Home <- Logos[match(day_schedule$Home,Logos$ESPN_name),]$TEAM
    
    day_schedule$`Neutral Site` <- as.logical(day_schedule$`Neutral Site`)
    
    day_schedule$Date <- ymd_hm(day_schedule$Date)
    
    day_schedule$`Away Score` <- as.numeric(day_schedule$`Away Score`)
    day_schedule$`Home Score` <- as.numeric(day_schedule$`Home Score`)
    
    #Reset index since non-D1 games are removed
    row.names(day_schedule) <- NULL
    
    return(day_schedule)
  }

}




