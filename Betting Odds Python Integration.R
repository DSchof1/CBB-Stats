#Author: Devan Scholefield


#You will need the reticulate package to execute python code
#You can un-comment lines 7, 8, and 9 and run them if you'd like it to automatically check and install the reticulate package

#list.of.packages <- c("reticulate)
# <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
#if(length(new.packages)) install.packages(new.packages, repos = "http://cran.us.r-project.org")



reticulate::virtualenv_create(envname = "python3_env", 
                              python = "python3")
reticulate::use_virtualenv('python3_env', required = TRUE)

#The following commented command will display what version of python is being used
#The version needs to be at least version 3.8 
#reticulate::py_config()

#This command can be used to remove the virtual environment
#reticulate::virtualenv_remove("python3_env")

reticulate::virtualenv_install("python3_env", 
                               packages = c("pytz","python-sbr","datetime", "fake_useragent")) 


reticulate::source_python("BettingOdds.py")

TodaysGamesOU <- PullOddsFunc("ou", books)
TodaysGamesML <- PullOddsFunc("moneyline", books)
TodaysGamesPS <- PullOddsFunc("pointspread", books)





