#Function to format the schedule component

schedule_display <- function(schedule_dataset){
  games <- list()
  for(i in (1:nrow(schedule_dataset))){
    if(isTRUE(schedule_dataset[,"Neutral Site"][i])){
      if(schedule_dataset[,"Home Win Probability"][i] > schedule_dataset[,"Away Win Probability"][i]){
        home_prob_colour <- "color:#00BF23"
        away_prob_colour <- "color:#333333"
      }
      else if(schedule_dataset[,"Away Win Probability"][i] > schedule_dataset[,"Home Win Probability"][i]){
        home_prob_colour <- "color:#333333"
        away_prob_colour <- "color:#00BF23"
      }
      else{
        home_prob_colour <- "color:red"
        away_prob_colour <- "color:red"
      }
      games[[length(games)+1]] = box(
        status="danger",
        width = 12,
        fluidRow(
          column(width = 1, trimws(format(schedule_dataset[,"Date"][i], format = "%l:%M %p", tz="America/Toronto")), align="center"),
          column(width = 2, "Neutral Site", align = "center"),
          column(width = 3, "Win Percentage", align = "center"),
          column(width = 3, "Expected Score", align = "center"),
          column(width = 3, "Expected Spread", align = "center")
        ),
        fluidRow(
          id = "team_display_schedule",
          column(width = 1, tags$img(src=schedule_dataset[,"Away Logo"][i], height="100%", width="100%")),
          column(width = 2, h4(schedule_dataset[,"Away"][i])),
          column(width = 3, h4(paste0(schedule_dataset[,"Away Win Probability"][i],"%")), align = "center", style = away_prob_colour),
          column(width = 3, h4(round(schedule_dataset[,"Away Expected Score"][i],2)), align = "center"),
          column(width = 3, "")
        ),
        fluidRow(
          id = "team_display_schedule",
          column(width = 1, tags$img(src=schedule_dataset[,"Home Logo"][i], height="100%", width="100%")),
          column(width = 2, h4(schedule_dataset[,"Home"][i])),
          column(width = 3, h4(paste0(schedule_dataset[,"Home Win Probability"][i],"%")), align = "center", style = home_prob_colour),
          column(width = 3, h4(round(schedule_dataset[,"Home Expected Score"][i],2)), align = "center"),
          column(width = 3, h4(sprintf("%+.2f", schedule_dataset[,"Home Team Spread"][i])), align = "center")
        )
      )
    }
    else{
      if(schedule_dataset[,"Home Win Probability"][i] > schedule_dataset[,"Away Win Probability"][i]){
        home_prob_colour <- "color:#00BF23"
        away_prob_colour <- "color:#333333"
      }
      else if(schedule_dataset[,"Away Win Probability"][i] > schedule_dataset[,"Home Win Probability"][i]){
        home_prob_colour <- "color:#333333"
        away_prob_colour <- "color:#00BF23"
      }
      else{
        home_prob_colour <- "color:red"
        away_prob_colour <- "color:red"
      }
      games[[length(games)+1]] = box(
        width = 12,
        fluidRow(
          column(width = 1, trimws(format(schedule_dataset[,"Date"][i], format = "%l:%M %p", tz="America/Toronto")), align="center"),
          column(width = 2, "", align = "center"),
          column(width = 3, "Win Percentage", align = "center"),
          column(width = 3, "Expected Score", align = "center"),
          column(width = 3, "Expected Spread", align = "center")
        ),
        fluidRow(
          id = "team_display_schedule",
          column(width = 1, tags$img(src=schedule_dataset[,"Away Logo"][i], height="100%", width="100%")),
          column(width = 2, h4(schedule_dataset[,"Away"][i])),
          column(width = 3, h4(paste0(schedule_dataset[,"Away Win Probability"][i],"%")), align = "center", style = away_prob_colour),
          column(width = 3, h4(round(schedule_dataset[,"Away Expected Score"][i],2)), align = "center"),
          column(width = 3, "")
        ),
        fluidRow(
          id = "team_display_schedule",
          column(width = 1, tags$img(src=schedule_dataset[,"Home Logo"][i], height="100%", width="100%")),
          column(width = 2, h4(schedule_dataset[,"Home"][i])),
          column(width = 3, h4(paste0(schedule_dataset[,"Home Win Probability"][i],"%")), align = "center", style = home_prob_colour),
          column(width = 3, h4(round(schedule_dataset[,"Home Expected Score"][i],2)), align = "center"),
          column(width = 3, h4(sprintf("%+.2f", schedule_dataset[,"Home Team Spread"][i])), align = "center")
        )
      )
    }
  }
  return(games)
}
  
