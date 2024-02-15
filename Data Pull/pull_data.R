#You may have to install some of these packages
#You can un-comment lines 7, 8, and 9 and run them if you'd like it to automatically check and install missing packages

#list.of.packages <- c("data.table","tidyverse", "XML", "rvest", "stringr", "plotly", "janitor", "readxl", "shiny", "shinydashboard", "httr", "shinyalert")
#new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
#if(length(new.packages)) install.packages(new.packages)

source("Data/year.R")

library(data.table)
library(tidyverse)
library(XML)
library(xml2)
library(rvest)
library(stringr)
library(plotly)
library(janitor)
library(readxl)
library(httr)


yr <- champ_year


set_config(config(ssl_verifypeer = FALSE))
options(RCurlOptions = list(ssl_verifypeer = FALSE))
options(rsconnect.check.certificate = FALSE)

#Logos and team names Dataset
Logos <- read_excel("Logos.xlsx")

#Using JSON data now, so this cleans it for use in R
#Due to a Lets Encrypt root certificate expiring the JSON method is now slightly deprecated and is adjusted here
ExactDataScrapeBT <- function(year){
  TheURL <- paste0("https://barttorvik.com/", as.character(year), "_team_results.json")
  WebScrape <- GET(TheURL)
  ExactCurrentYearData <- as.data.frame(do.call(rbind, lapply(content(WebScrape,"parsed"), as.vector)))
  
  
  ExactCurrentYearData <- setnames(ExactCurrentYearData, old = c(names(ExactCurrentYearData)), new = c("rank","TEAM","conf","record","ADJOE","oe Rank","ADJDE",
                                                                                                       "de Rank","BARTHAG",	"Bartrank",	"proj. W",	"Proj. L",	"Pro Con W",
                                                                                                       "Pro Con L",	"Con Rec.",	"sos",	"ncsos",	"consos",	"Proj. SOS",
                                                                                                       "Proj. Noncon SOS",	"Proj. Con SOS",	"elite SOS",	"elite noncon SOS",
                                                                                                       "Opp OE",	"Opp DE",	"Opp Proj. OE",	"Opp Proj DE",	"Con Adj OE",	"Con Adj DE",
                                                                                                       "Qual O",	"Qual D",	"Qual Barthag",	"Qual Games",	"FUN",	"ConPF",	"ConPA",
                                                                                                       "ConPoss",	"ConOE",	"ConDE",	"ConSOSRemain",	"Conf Win%",	"WAB",
                                                                                                       "WAB Rk",	"Fun Rk", "ADJ_T"))
  ExactCurrentYearData$TEAM <- as.character(ExactCurrentYearData$TEAM)
  ExactCurrentYearData$conf <- as.character(ExactCurrentYearData$conf)
  ExactCurrentYearData$record <- as.character(ExactCurrentYearData$record)
  ExactCurrentYearData$`Con Rec.` <- as.character(ExactCurrentYearData$`Con Rec.`)
  ExactCurrentYearData$rank <- as.integer(ExactCurrentYearData$rank)
  ExactCurrentYearData[,5:14] = as.numeric(as.matrix(ExactCurrentYearData[,5:14]))
  ExactCurrentYearData[,16:45] = as.numeric(as.matrix(ExactCurrentYearData[,16:45]))
  
  return(ExactCurrentYearData)
}
#ExactCurrentYearData <- ExactDataScrapeBT(yr)


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
#I believe that if you input a year that leads to a date beyond whatever today's date is causes it to just take the most up to date numbers

TeamRankingsStatPull <- function(StatToPull,year){
  RowIndex <- which(TeamRankingIndex$StatNames == StatToPull)
  PulledRow <- subset(TeamRankingIndex[RowIndex,])
  theurl <- paste0(PulledRow$url,"?date=",year,"-07-01")
  
  page <- read_html(theurl)
  tables <- html_table(page)
  StatDataset <- do.call(rbind, tables)
  StatDataset[StatDataset == "--" ] <- NA
  StatDataset <- StatDataset[complete.cases(StatDataset[3]),]
  
  
  StatDataset[c(3:8)] <- lapply(StatDataset[c(3:8)], function(x) as.numeric(gsub("%", "", x)))
  
  
  StatDataset[] <- lapply(StatDataset, function(x) {
    inds <- match(x, Logos$TeamRankingsName)
    ifelse(is.na(inds),x, Logos$TEAM[inds]) 
  })
  
  
  StatDataset <- StatDataset[ , !(names(StatDataset) %in% c("Rank"))]
  
  #names(StatDataset)[names(StatDataset) == 'Team'] <- 'team'
  
  
  return(StatDataset)
}

#For example this returns the 3 point percentage of all teams
#triplepct <- TeamRankingsStatPull("3FG %",2021)

#Adding some missing stats from the JSON dataset back to the dataset
#This also helps to get around the Let's Encrypt issue that has been plaguing the data pull
Add_to_JSON <- function(JSONDataSet, year){
  FullData <- merge(JSONDataSet,TeamRankingsStatPull("EFG %",year)[,c(1,2)], by.x="TEAM",by.y="Team",sort = FALSE)
  names(FullData)[ncol(FullData)] <- "EFG_O"
  FullData <- merge(FullData,TeamRankingsStatPull("OPP EFG %",year)[,c(1,2)], by.x="TEAM",by.y="Team",sort = FALSE)
  names(FullData)[ncol(FullData)] <- "EFG_D"
  FullData <- merge(FullData,TeamRankingsStatPull("TO/poss",year)[,c(1,2)], by.x="TEAM",by.y="Team",sort = FALSE)
  names(FullData)[ncol(FullData)] <- "TOR"
  FullData <- merge(FullData,TeamRankingsStatPull("Opp TO/poss",year)[,c(1,2)], by.x="TEAM",by.y="Team",sort = FALSE)
  names(FullData)[ncol(FullData)] <- "TORD"
  FullData <- merge(FullData,TeamRankingsStatPull("OReb %",year)[,c(1,2)], by.x="TEAM",by.y="Team",sort = FALSE)
  names(FullData)[ncol(FullData)] <- "ORB"
  FullData <- merge(FullData,TeamRankingsStatPull("Opp OReb %",year)[,c(1,2)], by.x="TEAM",by.y="Team",sort = FALSE)
  names(FullData)[ncol(FullData)] <- "DRB"
  
  FullData <- FullData %>% select(-contains(c("rank","Rank","Rk")))
  
  return(FullData)
  
}
#Example use
#Add_to_JSON(ExactCurrentYearData,2021)

#BTData <- Add_to_JSON(ExactDataScrapeBT(yr),yr)


#Function to add any of the stats from team rankings to the dataset
add_stats <- function(dataset,stats_to_add, yr){
  for(stat in stats_to_add){
    stat_dataset <- TeamRankingsStatPull(stat,yr)
    output_dataset <- cbind(dataset, stat_dataset[match(dataset$TEAM,stat_dataset$Team),][,2])
    names(output_dataset)[length(names(output_dataset))] <- stat 
  }
  return(output_dataset)
}

master_data <- add_stats(Add_to_JSON(ExactDataScrapeBT(yr),yr), "FGA/G", yr)


#Single row dataset of the NCAA averages for the current year
#Function to create a single row dataset of the NCAA averages for the current year
NCAA_Row <- function(dataset){
  NCAA <- dataset %>% summarise_if(is.numeric, mean, na.rm = TRUE)
  NCAA <- mutate(NCAA, "TEAM" = "NCAA")
  #NCAA <- relocate(NCAA, TEAM)
  
  #Barthag can take a value between 0 and 1
  
  NCAA$conf <- "NCAA"
  NCAA$record <- NA
  NCAA$`Con Rec.` <- NA
  
  NCAA <- NCAA[names(dataset)]
  
  return(NCAA)
  
}

NCAA <- NCAA_Row(master_data)


#Add NCAA data to the master dataset
master_data <- rbind(master_data, NCAA)



