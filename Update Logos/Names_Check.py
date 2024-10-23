import pandas as pd
import httpx
from bs4 import BeautifulSoup



logos_url = 'https://github.com/DSchof1/CBB-Stats/blob/master/Data/Logos.xlsx?raw=true'
logos = pd.read_excel(logos_url)


#year = int(r.yr)
def new_teams(year):
    bart_url = 'https://barttorvik.com/'+str(year)+'_team_results.json'
    bart_data = pd.read_json(bart_url)
    bart_col_names = ['rank','TEAM','conf','record','ADJOE','oeRank','ADJDE','deRank','BARTHAG','Bartrank','proj.W',
                      'Proj.L','ProConW','ProConL','ConRec.','sos','ncsos','consos','Proj.SOS','Proj.NonconSOS',
                      'Proj.ConSOS','eliteSOS','elitenonconSOS','OppOE','OppDE','OppProj.OE','OppProjDE','ConAdjOE',
                      'ConAdjDE','QualO','QualD','QualBarthag','QualGames','FUN','ConPF','ConPA','ConPoss','ConOE',
                      'ConDE','ConSOSRemain','ConfWin%','WAB','WABRk','FunRk','ADJ_T']
    bart_data.columns = bart_col_names
    new_teams = bart_data['TEAM'][~bart_data['TEAM'].isin(logos['TEAM'])].tolist()
    return new_teams


#Checking if there are updated logos
def new_logos(year):
    team_names = []
    logo_links = []
    link_directory = [[30,'a-c'],[31,'d-h'],[32,'i-m'],[33,'n-r'],[34,'s-t'],[35,'u-z']]
    for i in link_directory:
        new_logo_check_url = 'https://www.sportslogos.net/teams/list_by_year/'+str(i[0])+str(year-1)+'/'+str(year-1)+'_NCAA-'+i[1]+'_Logos/'
        new_logo_landing = httpx.get(new_logo_check_url)
        new_logo_soup = BeautifulSoup(new_logo_landing,'html.parser')
        new_logo_full_info = new_logo_soup.find('div', {'id': 'new_logos'})
        if new_logo_full_info == None:
            continue
        else:
            new_logo_info = new_logo_full_info.find_all('a', href=True)
            #Remove the "Back to Top" part which is always the last item
            del new_logo_info[-1]
            for team in range(0, len(new_logo_info)):
                #Get the team names with a new logo
                team_name = ' '.join(new_logo_info[team].text.split())
                team_names.append(team_name)
                new_logo_page_url = 'https://www.sportslogos.net/' + new_logo_info[team]['href']
                final_page = httpx.get(new_logo_page_url)
                final_page_soup = BeautifulSoup(final_page,'html.parser')
                image_link = final_page_soup.find_all('img', alt=True)[1]['src']
                logo_links.append(image_link)


    new_logos_df = pd.DataFrame(
        {'Team': team_names,
         'Logo': logo_links,
        })
    return new_logos_df


def updates(year):
    year = int(year)
    print('The following teams have been added to D1 and will require logo info!:\n')
    for i in new_teams(year):
        print(i, end='\n')
    print('')
    print('There are new logos for the following teams!:\n')
    print(new_logos(year))
    return new_logos(year)


