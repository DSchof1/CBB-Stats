#!/usr/bin/env python
# coding: utf-8

# In[422]:


#Author: Devan Scholefield
import os
import httpx
from bs4 import BeautifulSoup
import pandas as pd
pd.options.mode.chained_assignment = None  # default='warn'


# In[483]:


#If you run this too many times and too frequently you will get timeout errors
#In theory this only needs to be run once per year just before the season starts to update teams and logos

def logo_pull():
    
    Logos = pd.DataFrame(columns = ["Team Name", "Logo Link"])

    sportslogos_landing = httpx.get("https://www.sportslogos.net/teams/list_by_league/85/national_collegiate_athletic_assoc/ncaa/logos/")
    NCAA_teams = BeautifulSoup(sportslogos_landing)
    NCAA_links = []
    for a in NCAA_teams.find_all('a', href=True): 
        if a.text:
            NCAA_links.append(a['href'])
    NCAA_links = sorted(list(set([s for s in NCAA_links if "NCAA_Division_I_" in s])))

    for letter in NCAA_links:
        letter_list_unprocessed = httpx.get("https://www.sportslogos.net" + letter)
        letter_list = BeautifulSoup(letter_list_unprocessed)

        teams = []
        for team in letter_list.find_all('a', href=True): 
            if letter_list.text:
                teams.append(team['href'])

        logo_links = sorted(list(set([s for s in teams if "list_by_team" in s])))
        logo_links = sorted(logo_links,key=lambda x: x.split('/')[-2])

        for link in range(0,len(logo_links)):
            team_full_name = logo_links[link].split("/")[-2]
            main_logo_page_unprocessed = httpx.get("https://www.sportslogos.net" + logo_links[link])
            main_logo_page = BeautifulSoup(main_logo_page_unprocessed)

            teams_logos_all = []
            for logo_link in main_logo_page.find_all('a', href=True): 
                if main_logo_page.text:
                    teams_logos_all.append(logo_link['href'])

            teams_logos_all_sorted = sorted(list(set([s for s in teams_logos_all if "Primary_Logo" in s])))
            teams_logos_all_sorted = sorted(teams_logos_all_sorted,key=lambda x: x.split('/')[-2], reverse=True)

            final_logo_link_unprocessed = httpx.get('https://www.sportslogos.net/' + teams_logos_all_sorted[0])
            final_logo_link = BeautifulSoup(final_logo_link_unprocessed)

            final_image_link = []
            for image_link in final_logo_link.find_all('img', alt=True): 
                if image_link['alt'] != '':
                    final_image_link.append(image_link['src'])
                    final_image_link = "".join(final_image_link)

            df_new_row = pd.DataFrame({"Team Name": [team_full_name], "Logo Link": [final_image_link]})
            Logos = pd.concat([Logos, df_new_row])

    Logos = Logos.sort_values("Team Name")
    Logos = Logos.reset_index(drop=True)
    Logos["Team Name"] = Logos["Team Name"].str.replace('_',' ')
    
    #Separate the school name from the mascot name, not all are one word, but this should get a bunch
    Logos["Mascot"] = Logos["Team Name"].str.split().str[-1]
    Logos = Logos[["Team Name","Mascot", "Logo Link"]]
    #Remove the last word from the Team Name
    Logos["Team Name"] = Logos["Team Name"].str.rsplit(' ',n=1).str[0]
    
    
    #There are teams we must now manually adjust to extract the mascot since their mascot is longer than one word
    #However interestingly no mascot is longer than 2 words
    long_team_mascots = ["AIC Yellow", "Alabama Crimson", "Albany Great", "Arizona State Sun", "Arkansas-PB Golden",
                         "Arkansas State Red","Army Black", "California Golden", "Campbell Fighting", "Canisius Golden",
                         "Central Connecticut Blue","Clarkson Golden", "Cornell Big", "Dartmouth Big","Delaware Blue",
                         "DePaul Blue","Dixie State Red", "Duke Blue", "Evansville Purple","Georgia Tech Yellow",
                         "Illinois Fighting","Kent State Golden", "Lehigh Mountain", "Louisiana Ragin",
                         "MVSU Delta","Maine Black","Marist Red", "Marquette Golden", "Marshall Thundering",
                         "Middle Tennessee Blue","Minnesota Golden","Nevada Wolf", "Niagara Purple", "North Carolina Tar",
                         "North Dakota Fighting", "North Texas Mean","Notre Dame Fighting", "Oakland Golden",
                         "Oral Roberts Golden", "Penn State Nittany", "Presbyterian Blue","Rutgers Scarlet",
                         "Saint Francis Red", "Southern Miss Golden", "St Johns Red", "TCU Horned",
                         "Tennessee Tech Golden","Texas Tech Red", "Tulane Green", "Tulsa Golden", "UMass Lowell River",
                         "Wake Forest Demon"]
    
    #Fix the incorrect mascots
    for school in range(0,len(long_team_mascots)):
        index_of_row = Logos[Logos['Team Name'].str.contains(long_team_mascots[school])==True].index[0]
        Logos["Mascot"][index_of_row] = Logos["Team Name"][index_of_row].split()[-1] + " " + Logos["Mascot"][index_of_row]
        Logos["Team Name"][index_of_row] = Logos["Team Name"][index_of_row].rsplit(' ',1)[0]

        
    #UNC Asheville has a weird problem with its name that needs to be fixed
    Logos.loc[Logos["Team Name"] == "North CarolinaAsheville", "Team Name"] = "North Carolina Asheville"
    
    
    #Dropping duplicates suck because the database isn't always up to date with the new info so this is kind of manually done
    #Could drop all at once with an or (|), but apparently that method will become deprecated
    
    Logos = Logos.drop(Logos[Logos["Team Name"].str.contains("Arkansas State") & Logos["Mascot"].str.contains("Indians")].index)
    Logos = Logos.drop(Logos[Logos["Team Name"].str.contains("Dixie State") & Logos["Mascot"].str.contains("Rebels")].index)
    Logos = Logos.drop(Logos[Logos["Team Name"].str.contains("Dixie State") & Logos["Mascot"].str.contains("Red Storm")].index)
    Logos = Logos.drop(Logos[Logos["Team Name"].str.contains("Miami Ohio") & Logos["Mascot"].str.contains("Redskins")].index)
    Logos = Logos.drop(Logos[Logos["Team Name"].str.contains("Valparaiso") & Logos["Mascot"].str.contains("Crusaders")].index)
    Logos = Logos.drop(Logos[Logos["Team Name"].str.contains("Wayne State") & Logos["Mascot"].str.contains("Tartars")].index)

    
    
    return(Logos)
    

    
    
    


# In[ ]:


#I would only run this once before the season starts otherwise you'll get a timeout, but the sheet is important to have
#I have supplied the already compiled logo sheet in an excel format anyways
#Logos = logo_pull()
#Logos.to_excel("Logos_all.xlsx", index=False)

