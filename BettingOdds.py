#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb  1 13:07:41 2021

@author: Devan Scholefield
"""


#You may need to install pysbr and fake_useragent, you can use the following pip commands for this
#!pip install python-sbr
#Missing dependancy for pysbr for fake_useragent, need to install it
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
    
    return cl.dataframe(e)[cols]


#%%
#Testing with just bet365 right now to simplify things in shiny
bet365books = ["bet365"]

#Will use this later to allow users to choose their bookie, have to set thigns up with just one first though 
#books=["bet365","bodog","pinnacle"]

#Example use of the function, returns a data table with requested information
#PullOddsFunc("ou", books) 

#OUtodaysgames = PullOddsFunc("ou", books)






