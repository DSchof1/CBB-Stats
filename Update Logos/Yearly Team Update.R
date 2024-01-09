library(reticulate)

virtualenv_create(envname = "python3_env", python = "python3")
use_virtualenv('python3_env', required = TRUE)
virtualenv_install("python3_env", packages = c("bs4","httpx","openpyxl","pandas"))

source_python("Update Logos/Names_Check.py")

#Assuming Script.R is sourced where the variable yr is set
#Otherwise any (reasonable) integer year can be given
New_Logos <- updates(yr)

View(New_Logos)

