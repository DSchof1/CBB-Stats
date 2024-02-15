#Math functions for use in the app

#Chance of Team A beating Team B
Log5 <- function(PA, PB){
  WinningPercentage <- (PA - (PA*PB))/((PA+PB) - (2*PA*PB))
  return(WinningPercentage)
}

#Function to get the expected tempo between two teams
ExpTempo <- function(Team1, Team2, NCAA){
  ETempo <- (((Team1$ADJ_T/NCAA$ADJ_T)*(Team2$ADJ_T/NCAA$ADJ_T))*NCAA$ADJ_T)
  
  return(ETempo)
}

#Call this function to get the score for team1 against team2, reverse the inputs to get team2's score against team1
#This is the score on a neutral court, ie no homecourt advantage
GameScoreVS <- function(Team1, Team2, NCAA){
  ETempo <- ExpTempo(Team1, Team2, NCAA)/100
  #The NCAA average ADJOE cancels out so I have left it out to simplify the calculation
  Team1Score <- (Team1$ADJOE)*(Team2$ADJDE/NCAA$ADJDE)
  Team1ScoreAdj <- Team1Score*ETempo
  
  return(Team1ScoreAdj)
}

#Homecourt advantage for the home team has been set at a 1% increase in AdjOE and a 1% decrease in AdjDE
#Similarily the away team has been given a 1% decrease in AdjOE and a 1% increase in AdjDE

#Score for the Away Team
GameScoreAtAwayTeam <- function(Home, Away, NCAA){
  ETempo <- ExpTempo(Home, Away, NCAA)/100
  AwayScore <- ((Away$ADJOE*0.99)*((Home$ADJDE*0.99)/NCAA$ADJDE))*ETempo
  return(AwayScore)
}

#Score for the Home Team
GameScoreAtHomeTeam <- function(Home, Away, NCAA){
  ETempo <- ExpTempo(Home, Away, NCAA)/100
  HomeScore <- ((Home$ADJOE*1.01)*((Away$ADJDE*1.01)/NCAA$ADJDE))*ETempo
  return(HomeScore)
}


