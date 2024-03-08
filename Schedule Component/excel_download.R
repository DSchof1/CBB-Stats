#Function to convert dataframe with expected values into nice layout for download and use in excel

#Takes filled expected value dataframe as argument, returns nice format for excel
expected_excel_format <- function(filled_schedule){
  if(nrow(filled_schedule) == 0){
    return(filled_schedule)
  }
  output_df <- data.frame()
  filled_schedule$Date <- trimws(format(filled_schedule$Date, format = "%l:%M %p", tz="EST"))
  filled_schedule$`Away Win Probability` <- paste0(filled_schedule$`Away Win Probability`, "%")
  filled_schedule$`Home Win Probability` <- paste0(filled_schedule$`Home Win Probability`, "%")
  filled_schedule$`Away Expected Score` <- round(filled_schedule$`Away Expected Score`,2)
  filled_schedule$`Home Expected Score` <- round(filled_schedule$`Home Expected Score`,2)
  filled_schedule$`Home Team Spread` <- sprintf("%+.2f", filled_schedule$`Home Team Spread`)
  for(i in (1:nrow(filled_schedule))){
    if(isTRUE(filled_schedule$`Neutral Site`[i])){
      header <- c("Neutral Site", filled_schedule$Date[i], "Win Percentage", "Expected Score", "Home Spread")
    }
    else{
      header <- c(NA, filled_schedule$Date[i], "Win Percentage", "Expected Score", "Home Spread")
    }
    away_info <- c("Away", filled_schedule$Away[i], filled_schedule$`Away Win Probability`[i], filled_schedule$`Away Expected Score`[i], NA)
    home_info <- c("Home", filled_schedule$Home[i], filled_schedule$`Home Win Probability`[i], filled_schedule$`Home Expected Score`[i], filled_schedule$`Home Team Spread`[i])
    
    vec_list <- list(header, away_info, home_info)
    single_game <- do.call(rbind, vec_list) %>% as.data.frame
    single_game[nrow(single_game)+1,] <- NA
    
    output_df <- rbind(output_df, single_game)
  }
  return(output_df)
}



