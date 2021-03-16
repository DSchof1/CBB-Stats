#Author: Devan Scholefield


#You may have to install some of these packages
#You can un-comment lines 7, 8, and 9 and run them if you'd like it to automatically check and install missing packages

#list.of.packages <- c("data.table","tidyverse", "xml2", "XML", "rvest", "stringr", "plotly", "janitor", "readxl", "RJSONIO", "shiny", "shinydashboard")
#new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
#if(length(new.packages)) install.packages(new.packages, repos = "http://cran.us.r-project.org")

library(data.table)
library(tidyverse)
library(xml2)
library(XML)
library(rvest)
library(stringr)
library(plotly)
library(janitor)
library(readxl)
library(RJSONIO)


#Logos and team abbreviations Dataset
Logos <- read_excel("Logos.xlsx")

#Using JSON data now, so this cleans it for use in R
ExactDataScrapeBT <- function(year){
  TheURL <- paste0("https://barttorvik.com/", as.character(year), "_team_results.json")
  json_file <- fromJSON(TheURL)
  LoLoL <- as.data.frame(do.call(rbind, lapply(json_file, as.vector)))
  
  ExactCurrentYearData <- list()
  
  for (i in 1:length(LoLoL)){
    ExactCurrentYearData <- cbind(ExactCurrentYearData,as.vector(unlist(LoLoL[[i]])))
  }
  ExactCurrentYearData <- data.frame(matrix(unlist(ExactCurrentYearData), ncol = 45, byrow = F))
  
  ExactCurrentYearData <- setnames(ExactCurrentYearData, old = c(names(ExactCurrentYearData)), new = c("rank","team","conf","record","adjoe","oe Rank","adjde",
                                                                                                       "de Rank","barthag",	"Bartrank",	"proj. W",	"Proj. L",	"Pro Con W",
                                                                                                       "Pro Con L",	"Con Rec.",	"sos",	"ncsos",	"consos",	"Proj. SOS",
                                                                                                       "Proj. Noncon SOS",	"Proj. Con SOS",	"elite SOS",	"elite noncon SOS",
                                                                                                       "Opp OE",	"Opp DE",	"Opp Proj. OE",	"Opp Proj DE",	"Con Adj OE",	"Con Adj DE",
                                                                                                       "Qual O",	"Qual D",	"Qual Barthag",	"Qual Games",	"FUN",	"ConPF",	"ConPA",
                                                                                                       "ConPoss",	"ConOE",	"ConDE",	"ConSOSRemain",	"Conf Win%",	"WAB",
                                                                                                       "WAB Rk",	"Fun Rk", "adjt"))
  ExactCurrentYearData$rank <- as.integer(ExactCurrentYearData$rank)
  ExactCurrentYearData[,5:14] = as.numeric(as.matrix(ExactCurrentYearData[,5:14]))
  ExactCurrentYearData[,16:45] = as.numeric(as.matrix(ExactCurrentYearData[,16:45]))
  
  return(ExactCurrentYearData)
} 
ExactCurrentYearData <- ExactDataScrapeBT(2021)

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


BT2021DataNoDecimals <- suppressWarnings(BartDataScrape(2021))

#Getting more exact decimal points for ADJOE, ADJDE, and BARTHAG
#This helps to more accurately predict Log5 and Game Score
AdjustDecimals <- function(CurrentYearDataSet){
  CurrentYearDataSet$ADJOE <- ifelse(ExactCurrentYearData$team == CurrentYearDataSet$TEAM, ExactCurrentYearData$adjoe, NA)   
  CurrentYearDataSet$ADJDE <- ifelse(ExactCurrentYearData$team == CurrentYearDataSet$TEAM, ExactCurrentYearData$adjde, NA)
  CurrentYearDataSet$BARTHAG <- ifelse(ExactCurrentYearData$team == CurrentYearDataSet$TEAM, ExactCurrentYearData$barthag, NA)
  CurrentYearDataSet$ADJ_T <- ifelse(ExactCurrentYearData$team == CurrentYearDataSet$TEAM, ExactCurrentYearData$adjt, NA)
  
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

#Function to get a table of urls to all NCAA basketball stat tables on teamrankings.com
#Also has shortened variable explanations
TeamRankingsPull <- function(){
  
  tr_url <- "https://www.teamrankings.com/ncb/stats/"
  tr <- read_html(tr_url)
  
  tr_links <- tr %>% html_nodes("a") %>% html_attr("href")
  
  
  length(tr_links[str_detect(tr_links,"ncaa-basketball/stat")])
  ncb_links <- tr_links[str_detect(tr_links,"ncaa-basketball/stat")]
  ncbdf <- data.frame(ncb_links)
  StatNames <- c("ppg","avg scoring margin", "OE", "Floor %", "1stH pts/G", "2ndH pts/G", "OT pts/G",
                 "avg 1stH margin", "avg 2ndH margin", "OT margin", "pts from 2FG", "pts from 3FG",
                 "pct pts 2FG", "pct pts 3FG", "pct pts FT", "shooting %", "EFG %", "3FG %", "2FG %",
                 "FT %", "TS %", "FG made/G", "FGA/G", "3P made/G", "3PA/G", "FT made/G", "FTA/G",
                 "3FG rate", "2FG rate", "FTA per FGA", "FT made/100 pos", "FT rate", "non-blocked 2FG %",
                 "OReb/G", "DReb/G", "TeamReb/G", "TotReb/G", "OReb %", "DReb %", "TotReb %", "Blks/G",
                 "Steals/G", "Blk %", "Steals/poss", "Steal %", "Ast/G", "TO/G", "TO/poss", "Ast/TO",
                 "Ast/FG made", "Ast/poss", "TO %", "PF/G", "PF/poss", "PF %", "Opp PPG", "Opp avg score margin",
                 "D Eff", "Opp floor %", "Opp 1stH pts/G", "Opp 2ndH pts/G", "Opp OT pts/G", "Opp pts from 2FG",
                 "Opp pts from 3FG", "Opp pct pts from 2FG", "Opp pct pts from 3FG", "Opp pct pts from FT",
                 "Opp shooting %", "OPP EFG %", "Opp 3FG %", "Opp 2FG %", "Opp FT %", "Opp TS %", "Opp FG made/G",
                 "Opp FGA/G", "Opp 3P made/G", "Opp 3PA/G", "Opp FT made/G", "Opp FTA/G", "Opp 3FG rate",
                 "Opp 2FG rate", "Opp FTA per FGA", "Opp FT made/100 pos", "Opp FT rate", "Opp non-blocked 2FG %",
                 "Opp OReb/G", "Opp DReb/G", "Opp TeamReb/G", "Opp TotReb/G", "Opp OReb %", "Opp DReb %",
                 "Opp Blks/G", "Opp Steals/G", "Opp Blk %", "Opp Steals/poss", "Opp Steal %", "Opp Ast/G",
                 "Opp TO/G", "Opp Ast/TO", "Opp Ast/FG made", "Opp Ast/poss", "Opp TO/poss", "Opp TO %",
                 "Opp PF/G", "Opp PF/poss", "Opp PF %", "G played", "poss/G", "extra chances/G", "Effective poss ratio",
                 "Opp Effective poss ratio", "W % all games", "W % close games", "Opp W % all games", "Opp W % close games")
  
  ncbdf <- ncbdf %>% mutate(StatNames)
  ncbdf <- ncbdf %>% mutate(url = paste0('https://www.teamrankings.com', ncb_links))
  
  return(ncbdf)
}

TeamRankingIndex <- TeamRankingsPull()

#Function to pull a specific table from Team Rankings
#See TeamRankingIndex$explanation to see the list of stat explanations

TeamRankingsStatPull <- function(StatToPull){
  RowIndex <- which(TeamRankingIndex$StatNames == StatToPull)
  PulledRow <- subset(TeamRankingIndex[RowIndex,])
  theurl <- PulledRow$url
  
  page <- read_html(theurl)
  tables <- html_table(page)
  StatDataset <- do.call(rbind, tables)
  StatDataset[StatDataset == "--" ] <- NA
  StatDataset <- StatDataset[complete.cases(StatDataset[3]),]
  
  for (i in 3:ncol(StatDataset)){
    StatDataset[,i] <- as.numeric(sub("%", "",StatDataset[,i],fixed=TRUE))
  }
  
  StatDataset[] <- lapply(StatDataset, function(x) {
    inds <- match(x, Logos$TeamRankingsName)
    ifelse(is.na(inds),x, Logos$TEAM[inds]) 
  })
  
  StatDataset <- StatDataset[ , !(names(StatDataset) %in% c("Rank"))]
  
  return(StatDataset)
}

#For example this returns the 3 point percentage of all teams
#triplepct <- TeamRankingsStatPull("3FG %")



