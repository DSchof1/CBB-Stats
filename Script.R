#Author: Devan Scholefield


#You may have to install some of these packages
#You can un-comment lines 7, 8, and 9 and run them if you'd like it to automatically check and install missing packages

#list.of.packages <- c("data.table","tidyverse", "XML", "rvest", "stringr", "plotly", "janitor", "readxl")
#new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
#if(length(new.packages)) install.packages(new.packages, repos = "http://cran.us.r-project.org")

library(data.table)
library(tidyverse)
library(XML)
library(rvest)
library(stringr)
library(plotly)
library(janitor)
library(readxl)

#Logos and team abbreviations Dataset
Logos <- read_excel("Logos.xlsx")

#csv is read in weird so the column names don't matchup properly, I'll fix it later
ExactCurrentYearData <- read.csv("http://barttorvik.com/2021_team_results.csv")

#Function to scrape and clean current Bart Torvik data on College Basketball Teams
BartDataScrape <- function(year){
  
  theUrl <- paste0("https://barttorvik.com/trank.php?year=", as.character(year))
  page <- read_html(theUrl)
  
  #Remove the class lowrow that has today's games and ranks of metrics and messes up data if not removed
  lowrow <- page %>% html_nodes(".lowrow")
  xml_remove(lowrow)
  
  #Create the table from scraped data
  tables <- page %>% html_nodes("table") %>% html_table()
  BTData <- as.data.table(tables[1])
  
  #Set the first row as column names
  BTData <- BTData %>% row_to_names(row_number = 1, remove_row=TRUE)
  
  #Remove unnecessary columns 
  BTData <- BTData[,-c(1,3,22)]
  
  #NAs introduced here for certain rows, but that's ok
  BTData <- separate(data = BTData, col = Rec, into = c("W", "L"), sep = "-")
  
  #Remove Rows with NAs, ie removes annoying header rows
  BTData <- na.omit(BTData)
  
  #Add Year as a value
  BTData <- mutate(BTData, "YEAR" = year)
  
  #Rename columns to be consistent
  colnames(BTData)[1] <- "TEAM"
  colnames(BTData)[2] <- "G"
  colnames(BTData)[3] <- "W"
  colnames(BTData)[4] <- "L"
  colnames(BTData)[5] <- "ADJOE"
  colnames(BTData)[6] <- "ADJDE"
  colnames(BTData)[7] <- "BARTHAG"
  colnames(BTData)[8] <- "EFG_O"
  colnames(BTData)[9] <- "EFG_D"
  colnames(BTData)[10] <- "TOR"
  colnames(BTData)[11] <- "TORD"
  colnames(BTData)[12] <- "ORB"
  colnames(BTData)[13] <- "DRB"
  colnames(BTData)[14] <- "FTR"
  colnames(BTData)[15] <- "FTRD"
  colnames(BTData)[16] <- "X2P_O"
  colnames(BTData)[17] <- "X2P_D"
  colnames(BTData)[18] <- "X3P_O"
  colnames(BTData)[19] <- "X3P_D"
  colnames(BTData)[20] <- "ADJ_T"
  
  #Convert characters to numeric form
  BTData$G <- as.integer(BTData$G)
  BTData$W <- as.integer(BTData$W)
  BTData$L <- as.integer(BTData$L)
  BTData$ADJOE <- as.numeric(BTData$ADJOE)
  BTData$ADJDE <- as.numeric(BTData$ADJDE)
  BTData$BARTHAG <- as.numeric(BTData$BARTHAG)
  BTData$EFG_O <- as.numeric(BTData$EFG_O)
  BTData$EFG_D <- as.numeric(BTData$EFG_D)
  BTData$TOR <- as.numeric(BTData$TOR)
  BTData$TORD <- as.numeric(BTData$TORD)
  BTData$ORB <- as.numeric(BTData$ORB)
  BTData$DRB <- as.numeric(BTData$DRB)
  BTData$FTR <- as.numeric(BTData$FTR)
  BTData$FTRD <- as.numeric(BTData$FTRD)
  BTData$X2P_O <- as.numeric(BTData$X2P_O)
  BTData$X2P_D <- as.numeric(BTData$X2P_D)
  BTData$X3P_O <- as.numeric(BTData$X3P_O)
  BTData$X3P_D <- as.numeric(BTData$X3P_D)
  BTData$ADJ_T <- as.numeric(BTData$ADJ_T)
  

  return(BTData)

}

#Chance of Team A beating Team B
Log5 <- function(PA, PB){
  WinningPercentage <- (PA - (PA*PB))/((PA+PB) - (2*PA*PB))
  return(WinningPercentage)
}


#Call this function to get the score for team1 against team2, reverse the inputs to get team2's score against team1
#This is the score on a neutral court, ie no homecourt advantage
GameScoreVS <- function(Team1, Team2, NCAA){
  ETempo <- (((Team1$ADJ_T/NCAA$ADJ_T)*(Team2$ADJ_T/NCAA$ADJ_T))*NCAA$ADJ_T)/100
  #The NCAA average ADJOE cancels out so I have left it out to simplify the calculation
  Team1Score <- (Team1$ADJOE)*(Team2$ADJDE/NCAA$ADJDE)
  Team1ScoreAdj <- Team1Score*ETempo

  return(Team1ScoreAdj)
}

#Homecourt advantage for the home team has been set at a 1% increase in AdjOE and a 1% decrease in AdjDE
#Similarily the away team has been given a 1% decrease in AdjOE and a 1% increase in AdjDE

#Score for the Away Team
GameScoreAtAwayTeam <- function(Home, Away, NCAA){
  ETempo <- (((Home$ADJ_T/NCAA$ADJ_T)*(Away$ADJ_T/NCAA$ADJ_T))*NCAA$ADJ_T)/100
  AwayScore <- ((Away$ADJOE*0.99)*((Home$ADJDE*0.99)/NCAA$ADJDE))*ETempo
  return(AwayScore)
}

#Score for the Home Team
GameScoreAtHomeTeam <- function(Home, Away, NCAA){
  ETempo <- (((Home$ADJ_T/NCAA$ADJ_T)*(Away$ADJ_T/NCAA$ADJ_T))*NCAA$ADJ_T)/100
  HomeScore <- ((Home$ADJOE*1.01)*((Away$ADJDE*1.01)/NCAA$ADJDE))*ETempo
  return(HomeScore)
}

#I will be using this later for some regression models, but it takes time to scrape prior data so it is omitted for now
if(F){
  #Empty data frame to be filled with training data for regression analysis
  BTData <- data.table()
  
  # Build the data table
  for (year in 2008:2019) {
    BTYear <- BartDataScrape(year)
    BTData <- rbind(BTData, BTYear)
  }
}


BT2021DataNoDecimals <- suppressWarnings(BartDataScrape(2021))

#Getting more exact decimal points for ADJOE, ADJDE, and BARTHAG
#This helps to more accurately predict Log5 and Game Score
AdjustDecimals <- function(CurrentYearDataSet){
  CurrentYearDataSet$ADJOE <- ifelse(ExactCurrentYearData$rank == CurrentYearDataSet$TEAM, ExactCurrentYearData$record, NA)   
  CurrentYearDataSet$ADJDE <- ifelse(ExactCurrentYearData$rank == CurrentYearDataSet$TEAM, ExactCurrentYearData$oe.Rank, NA)
  CurrentYearDataSet$BARTHAG <- ifelse(ExactCurrentYearData$rank == CurrentYearDataSet$TEAM, ExactCurrentYearData$de.Rank, NA)
  CurrentYearDataSet$ADJ_T <- ifelse(ExactCurrentYearData$rank == CurrentYearDataSet$TEAM, ExactCurrentYearData$Fun.Rk..adjt, NA)
  
  return(CurrentYearDataSet)
}

BT2021Data <- AdjustDecimals(BT2021DataNoDecimals)


#Single row dataset of the NCAA averages for the current year
NCAA <- BT2021Data %>% summarise_if(is.numeric, mean, na.rm = TRUE)
NCAA <- mutate(NCAA, "TEAM" = "NCAA")
NCAA <- relocate(NCAA, TEAM)

#All Barthag ratings are based against the NCAA average, therefore this must be changed to 0.5
#Barthag can take a value between 0 and 1
NCAA$BARTHAG <- 0.5


#Function to pull field goal attempts and games played from sports reference
#Games played is pulled to compare to Bart Torvik to make sure everything is up to date

FieldGoalAttempts <- function(year){
  url <- paste0("https://www.sports-reference.com/cbb/seasons/",as.character(year),"-school-stats.html")
  page <- read_html(url)
  
  
  tables <- page %>% html_nodes("table") %>% html_table()
  FGATable <- as.data.table(tables[1])
  FGATable <- data.frame(FGATable)
  keeps <- c("X.1","Overall","Totals.1","Totals.2","Totals.4","Totals.5")
  FGATable <- FGATable[keeps]
  FGATable <- FGATable %>% row_to_names(row_number = 1, remove_row=TRUE)
  
  FGATable$G <- suppressWarnings(as.integer(FGATable$G))
  FGATable$FG <- suppressWarnings(as.integer(FGATable$FG))
  FGATable$FGA <- suppressWarnings(as.integer(FGATable$FGA))
  FGATable$`3P` <- suppressWarnings(as.integer(FGATable$`3P`))
  FGATable$`3PA` <- suppressWarnings(as.integer(FGATable$`3PA`))
  
  FGATable <- na.omit(FGATable)
  
  #Add a column of FG attempts per game
  FGATable$FGAPG <- (FGATable$FGA/FGATable$G)
  
  #Add a column of 3 point FG attempts per game
  FGATable$FG3APG <- (FGATable$`3PA`/FGATable$G)
  
  
  return(FGATable)
  
}


FGATable <- FieldGoalAttempts(2021)
