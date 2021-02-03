#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb  1 13:07:41 2021

@author: Devan Scholefield
"""


#You may need to install pysbr and fake_useragent, you can use the following pip commands for this
#!pip install python-sbr
#Missing dependancy fake_useragent for pysbr, need to install it
#!pip install fake_useragent

#%%
import pytz
import pysbr
import datetime

#%%
#Function to pull betting odds using pysbr from sportsbookreview.com
#OddsType: pointspread, moneyline, ou
#Bookies: list of the bookies to pull odds from
def PullOddsFunc (OddsType, Bookies):
    
    #Account for EST, then strip time so it only displays games for 1 day
    my_date = datetime.datetime.now(pytz.timezone("EST"))
    dt = datetime.datetime(my_date.year, my_date.month, my_date.day)
    
    sport = pysbr.NCAAB()
    sb=pysbr.Sportsbook()
    cols = ["event", "participant", "sportsbook", "spread / total", "decimal odds", "american odds"]
    e = pysbr.EventsByDate(sport.league_id, dt)

    cl = pysbr.CurrentLines(e.ids(), sport.market_ids([OddsType]), sb.ids(Bookies))
    
    output = cl.dataframe(e)[cols]
    
    #Abbreviaition isn't included in ou
    if OddsType == "moneyline" or "pointspread":
        if len(output[(output['participant'] == "DSU") & output['event'].str.contains('Dixie')]) >= 1:
            #Resolve DSU conflict by changing Dixie St. abbreviation to DXST
            output.loc[(output['participant'] == "DSU") & (output['event'].str.contains('Dixie')) , 'participant'] = 'DXST'
            return output
        else:
            return output
    else:
            return output

#%%
#Testing with just bodog right now because they come out with moneyline odds first and it simplifies things in shiny
bodogbooks = ["bodog"]

#Will use this later to allow users to choose their bookie, have to set things up with just one first though 
#books=["bet365","bodog","pinnacle"]

#Example uses of the function, returns a data table with requested information
#PullOddsFunc("moneyline", bodogbooks) 
#OUtodaysgames = PullOddsFunc("ou", bodogbooks)

#%%
#Used this to get a close approximation of the proper abbreviation for each team

# TeamKeys = pysbr.NCAAB()._team_ids
# import pandas
# import openpyxl


# Names = list(TeamKeys['name'].keys())
# Abbreviations = list(TeamKeys['sbr abbreviation'].keys())

# Abbreviations = [x.upper() for x in Abbreviations]


# df = pandas.DataFrame(Names,columns=['TEAM'])
# df['Abbreviations'] = Abbreviations

#Export into Excel to matchup with team logo links
# df.to_excel (r'NameAbbrevs.xlsx', index = False, header=True)

    
    
