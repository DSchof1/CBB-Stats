#!/usr/bin/env python
# coding: utf-8

# In[155]:


#Author: Devan Scholefield
#Add the Get_Logos folder to the working directory
import sys
import os
sys.path.append(os.path.dirname(os.getcwd()) + "/"+ os.path.basename(os.getcwd()) + "/Get_Logos")


# In[ ]:


import pandas as pd
import difflib
import Bart_Torvik_Team_Names_Pull as bt
import TeamRankings_Name_Pull as tr
import Fetch_Logos as fl
import warnings
from bs4 import GuessedAtParserWarning
warnings.filterwarnings('ignore', category=GuessedAtParserWarning)


# In[156]:


def logo_master_create(year):
    Logos_All = pd.read_excel("Logos_All.xlsx")
    Master = pd.DataFrame(columns = ["TEAM", "TeamRankingsName","SportsLogosName", "LOGO"])
    Master["TEAM"] = bt.barttorvik_name_pull(year)
    
    #Better to load this once than use it every time
    team_rankings_names = tr.team_rankings_name_pull()
    
    #This gets us very close, but there are a few that confound it which we can fix manually and some that need to be manually fixed after
    for team in range(0,len(Master["TEAM"])):
        teamrankings_match = difflib.get_close_matches(Master["TEAM"][team],team_rankings_names, n=3)
        sportslogos_match = difflib.get_close_matches(Master["TEAM"][team],Logos_All["Team Name"], n=3)
        try:
            Master.at[team, "TeamRankingsName"] = teamrankings_match[0]
        except IndexError:
            pass
        try:
            Master.at[team, "SportsLogosName"] = sportslogos_match[0]
        except IndexError:
            pass

    #I'm separating out each column to make it easier to read and match up later/adjust if data changes
    #These are for entries missing values
    #For teamrankings.com
    Master.loc[Master.TEAM == "Fort Wayne", "TeamRankingsName"] = "IPFW"
    Master.loc[Master.TEAM == "LIU Brooklyn", "TeamRankingsName"] = "LIU"
    Master.loc[Master.TEAM == "Massachusetts", "TeamRankingsName"] = "U Mass"
    Master.loc[Master.TEAM == "Texas A&M Corpus Chris", "TeamRankingsName"] = "TX A&M-CC"
    Master.loc[Master.TEAM == "UT Rio Grande Valley", "TeamRankingsName"] = "TX-Pan Am"
    Master.loc[Master.TEAM == "UTEP", "TeamRankingsName"] = "TX El Paso"
    Master.loc[Master.TEAM == "UTSA", "TeamRankingsName"] = "TX-San Ant"
    Master.loc[Master.TEAM == "VMI", "TeamRankingsName"] = "VA Military"

    #For sportslogos.net
    Master.loc[Master.TEAM == "BYU", "SportsLogosName"] = "Brigham Young"
    Master.loc[Master.TEAM == "Queens", "SportsLogosName"] = None
    Master.loc[Master.TEAM == "UC Irvine", "SportsLogosName"] = "California-Irvine"
    Master.loc[Master.TEAM == "USC", "SportsLogosName"] = "Southern California"
    Master.loc[Master.TEAM == "UT Rio Grande Valley", "SportsLogosName"] = "UTRGV"
    Master.loc[Master.TEAM == "UTSA", "SportsLogosName"] = "Texas-SA"

    
    #These are fixes for ones that were difflib'd incorrectly
    #For teamrankings.com
    Master.loc[Master.TEAM == "Appalachian St.", "TeamRankingsName"] = "App State"
    Master.loc[Master.TEAM == "East Tennessee St.", "TeamRankingsName"] = "E Tenn St"
    Master.loc[Master.TEAM == "FIU", "TeamRankingsName"] = "Florida Intl"
    Master.loc[Master.TEAM == "George Washington", "TeamRankingsName"] = "Geo Wshgtn"
    Master.loc[Master.TEAM == "Georgia Southern", "TeamRankingsName"] = "GA Southern"
    Master.loc[Master.TEAM == "Georgia Tech", "TeamRankingsName"] = "GA Tech"
    Master.loc[Master.TEAM == "Illinois Chicago", "TeamRankingsName"] = "IL-Chicago"
    Master.loc[Master.TEAM == "Louisiana Monroe", "TeamRankingsName"] = "LA Monroe"
    Master.loc[Master.TEAM == "Louisiana Tech", "TeamRankingsName"] = "LA Tech"
    Master.loc[Master.TEAM == "Mississippi St", "TeamRankingsName"] = "Miss State"
    Master.loc[Master.TEAM == "Mississippi Valley St.", "TeamRankingsName"] = "Miss Val St"
    Master.loc[Master.TEAM == "New Mexico St.", "TeamRankingsName"] = "N Mex State"
    Master.loc[Master.TEAM == "North Carolina A&T", "TeamRankingsName"] = "NC A&T"
    Master.loc[Master.TEAM == "North Carolina St.", "TeamRankingsName"] = "NC State"
    Master.loc[Master.TEAM == "North Dakota St.", "TeamRankingsName"] = "N Dakota St"
    Master.loc[Master.TEAM == "Northern Iowa", "TeamRankingsName"] = "N Iowa"
    Master.loc[Master.TEAM == "Northwestern St.", "TeamRankingsName"] = "NW State"
    Master.loc[Master.TEAM == "SMU", "TeamRankingsName"] = "S Methodist"
    Master.loc[Master.TEAM == "Sacramento St.", "TeamRankingsName"] = "Sac State"
    Master.loc[Master.TEAM == "South Carolina St.", "TeamRankingsName"] = "S Car State"
    Master.loc[Master.TEAM == "South Dakota St.", "TeamRankingsName"] = "S Dakota St"
    Master.loc[Master.TEAM == "Southeast Missouri St.", "TeamRankingsName"] = "SE Missouri"
    Master.loc[Master.TEAM == "Southern Miss", "TeamRankingsName"] = "S Mississippi"
    Master.loc[Master.TEAM == "Southern Utah", "TeamRankingsName"] = "S Utah"
    Master.loc[Master.TEAM == "TCU", "TeamRankingsName"] = "TX Christian"
    Master.loc[Master.TEAM == "Tennessee Martin", "TeamRankingsName"] = "TN Martin"
    Master.loc[Master.TEAM == "Tennessee St.", "TeamRankingsName"] = "TN State"
    Master.loc[Master.TEAM == "Tennessee Tech", "TeamRankingsName"] = "TN Tech"
    Master.loc[Master.TEAM == "Texas A&M Commerce", "TeamRankingsName"] = "TX A&M-Com"
    Master.loc[Master.TEAM == "UC Santa Barbara", "TeamRankingsName"] = "UCSB"
    Master.loc[Master.TEAM == "UCF", "TeamRankingsName"] = "Central FL"
    Master.loc[Master.TEAM == "UMBC", "TeamRankingsName"] = "Maryland BC"
    Master.loc[Master.TEAM == "Virginia Tech", "TeamRankingsName"] = "VA Tech"
    Master.loc[Master.TEAM == "Washington St.", "TeamRankingsName"] = "Wash State"


    #For sportslogos.net
    Master.loc[Master.TEAM == "Charleston Southern", "SportsLogosName"] = "CSU"
    Master.loc[Master.TEAM == "Connecticut", "SportsLogosName"] = "UConn"
    Master.loc[Master.TEAM == "East Tennessee St.", "SportsLogosName"] = "ETSU"
    Master.loc[Master.TEAM == "LIU Brooklyn", "SportsLogosName"] = "LIU"
    Master.loc[Master.TEAM == "Lindenwood", "SportsLogosName"] = None
    Master.loc[Master.TEAM == "Louisiana Lafayette", "SportsLogosName"] = "Louisiana"
    Master.loc[Master.TEAM == "Loyola Chicago", "SportsLogosName"] = "Loyola"
    Master.loc[Master.TEAM == "Loyola MD", "SportsLogosName"] = "Loyola-Maryland"
    Master.loc[Master.TEAM == "Mississippi Valley St.", "SportsLogosName"] = "MVSU"
    Master.loc[Master.TEAM == "North Carolina Central", "SportsLogosName"] = "NCCU"
    Master.loc[Master.TEAM == "North Florida", "SportsLogosName"] = "UNF"
    Master.loc[Master.TEAM == "Southeast Missouri St.", "SportsLogosName"] = "SE Missouri State"
    Master.loc[Master.TEAM == "Southern Indiana", "SportsLogosName"] = None
    Master.loc[Master.TEAM == "St. Francis PA", "SportsLogosName"] = "Saint Francis"
    Master.loc[Master.TEAM == "Stonehill", "SportsLogosName"] = None
    Master.loc[Master.TEAM == "Tennessee Martin", "SportsLogosName"] = "UT Martin"
    Master.loc[Master.TEAM == "Texas A&M Commerce", "SportsLogosName"] = None
    Master.loc[Master.TEAM == "UC Davis", "SportsLogosName"] = "California Davis"
    Master.loc[Master.TEAM == "UC Santa Barbara", "SportsLogosName"] = "UCSB"
    Master.loc[Master.TEAM == "UCF", "SportsLogosName"] = "Central Florida"
    Master.loc[Master.TEAM == "Utah Tech", "SportsLogosName"] = "Dixie State"


    for team_name in range(0,len(Master["TEAM"])):
        try:
            logo_link = Logos_All.loc[Logos_All["Team Name"] == Master.at[team_name, "SportsLogosName"],"Logo Link"].values.item()
            Master.at[team_name, "LOGO"] = logo_link
        except ValueError:
            pass

        
    #Fill in the few blank logos with some other source
    Master.loc[Master.TEAM == "Lindenwood", "LOGO"] = "https://en.wikipedia.org/wiki/Lindenwood_Lions#/media/File:Lindenwood_Lions_logo.svg"
    Master.loc[Master.TEAM == "Queens", "LOGO"] = "https://en.wikipedia.org/wiki/Queens_Royals#/media/File:Queens_Royals_primary_logo.svg"
    Master.loc[Master.TEAM == "Southern Indiana", "LOGO"] = "https://en.wikipedia.org/wiki/Southern_Indiana_Screaming_Eagles#/media/File:Southern_Indiana_Screaming_Eagles_logo.svg"
    Master.loc[Master.TEAM == "Stonehill", "LOGO"] = "https://en.wikipedia.org/wiki/Stonehill_Skyhawks_men's_basketball#/media/File:Stonehill_Skyhawks_logo.svg"
    Master.loc[Master.TEAM == "Texas A&M Commerce", "LOGO"] = "https://en.wikipedia.org/wiki/Texas_A%26M%E2%80%93Commerce_Lions#/media/File:Texas_A&M%E2%80%93Commerce_Lions_logo.svg"

    return(Master)



# In[158]:


Master = logo_master_create(2023)


# In[161]:


Master.to_excel("Logos.xlsx", index=False)

