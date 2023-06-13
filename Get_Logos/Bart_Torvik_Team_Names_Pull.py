#!/usr/bin/env python
# coding: utf-8

# In[26]:


#Author: Devan Scholefield
import httpx
import json
import pandas as pd
pd.options.mode.chained_assignment = None  # default='warn'


# In[23]:


def barttorvik_name_pull(year):
    bart_page_unprocessed = httpx.get("https://barttorvik.com/"+str(year)+"_team_results.json")
    bart_page = bart_page_unprocessed.json()
    school_names = []
    for i in range(0, len(bart_page)):
        school_names.append(bart_page[i][1])

    school_names = sorted(school_names)
    
    return(school_names)


# In[24]:


school_names = barttorvik_name_pull(2023)

