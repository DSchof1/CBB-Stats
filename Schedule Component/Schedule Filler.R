source("Schedule Component/Schedule For Date.R")
library(dplyr)

#Calculate expected game scores
#Takes schedule dataframe created from "Schedule For Date.R" as an argument
#Must have master_data in global environment
expected_values <- function(day_schedule){
  if(nrow(day_schedule)==0){
    return(day_schedule)
  }
  
  #Add expected score columns
  day_schedule$`Away Expected Score` <- NA
  day_schedule <- day_schedule %>% relocate(`Away Expected Score`, .after=`Away Score`)
  day_schedule$`Home Expected Score` <- NA
  day_schedule <- day_schedule %>% relocate(`Home Expected Score`, .after=`Home Score`)
  
  #Add win probability columns
  day_schedule$`Away Win Probability` <- NA
  day_schedule <- day_schedule %>% relocate(`Away Win Probability`, .after=`Away Expected Score`)
  day_schedule$`Home Win Probability` <- NA
  day_schedule <- day_schedule %>% relocate(`Home Win Probability`, .after=`Home Expected Score`)
  
  #Add a home_team_spread column
  day_schedule$`Home Team Spread` <- NA
  day_schedule <- day_schedule %>% relocate(`Home Team Spread`, .after=`Home Win Probability`)
  
  for(game in 1:nrow(day_schedule)){
    
    away_team <- filter(master_data, TEAM == day_schedule$Away[game])
    home_team <- filter(master_data, TEAM == day_schedule$Home[game])
    EHomePoss <- (as.numeric(home_team$`FGA/G`)*(ExpTempo(home_team, away_team, NCAA)))/home_team$ADJ_T
    EAwayPoss <- (as.numeric(away_team$`FGA/G`)*(ExpTempo(home_team, away_team, NCAA)))/away_team$ADJ_T
    EHomeEFG <- ((home_team$EFG_O/NCAA$EFG_O)*(away_team$EFG_D/NCAA$EFG_D)*home_team$EFG_O)/100
    EAwayEFG <- ((away_team$EFG_O/NCAA$EFG_O)*(home_team$EFG_D/NCAA$EFG_D)*away_team$EFG_O)/100
    
    HomeSD <- sqrt(EHomePoss*EHomeEFG*(1-EHomeEFG))*2
    AwaySD <- sqrt(EAwayPoss*EAwayEFG*(1-EAwayEFG))*2
    
    if(isTRUE(day_schedule$`Neutral Site`[game])){
      EAwayScore <- GameScoreVS(away_team, home_team, NCAA)
      EHomeScore <- GameScoreVS(home_team, away_team, NCAA)
    }
    else{
      EAwayScore <- GameScoreAtAwayTeam(home_team, away_team, NCAA)
      EHomeScore <- GameScoreAtHomeTeam(home_team, away_team, NCAA)
    }
    
    z_home <- pnorm((EHomeScore - EAwayScore)/(sqrt(HomeSD^2 + AwaySD^2)))
    z_away <- pnorm((EAwayScore - EHomeScore)/(sqrt(HomeSD^2 + AwaySD^2)))
    
    day_schedule$`Away Win Probability`[game] <- round(z_away*100,2)
    day_schedule$`Home Win Probability`[game] <- round(z_home*100,2)
    day_schedule$`Away Expected Score`[game] <- EAwayScore
    day_schedule$`Home Expected Score`[game] <- EHomeScore
    day_schedule$`Home Team Spread`[game] <- day_schedule$`Away Expected Score`[game] - day_schedule$`Home Expected Score`[game]

  }
  return(day_schedule)
  
}



