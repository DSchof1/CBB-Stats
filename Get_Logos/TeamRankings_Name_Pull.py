#!/usr/bin/env python
# coding: utf-8

# In[61]:


#Author: Devan Scholefield
import httpx
from bs4 import BeautifulSoup
import pandas as pd
pd.options.mode.chained_assignment = None  # default='warn'


# In[67]:


def team_rankings_name_pull():
    teams_page_unprocessed = httpx.get("https://www.teamrankings.com/ncb/")
    teams_page = BeautifulSoup(teams_page_unprocessed)
    mydivs = teams_page.find_all("div", {"class": "table-team-logo-text"})
    team_divs = []
    for x in mydivs:
        team_divs.append(str(x))
    team_name = [x.split('</a>',1)[0] for x in team_divs]
    team_name = [x.rsplit('>',1)[1] for x in team_name]
    team_name = [x.replace("amp;","") for x in team_name]
    team_names = sorted(team_name)
    
    return(team_names)
    

    


# In[63]:


team_names = team_rankings_name_pull()

