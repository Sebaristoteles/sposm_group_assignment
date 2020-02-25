#install.packages("rsconnect")
library(rsconnect)
library(here)

# don't forget token to install
# rsconnect::setAccountInfo(name='', token ='', secret = '')

#rm(list=ls(all=TRUE))

# --------------------------------------------- copy need files to app-foldercreate 

# create main directory if not existing
ifelse(!dir.exists(here::here("app_ger_power_plant_explorer")), dir.create(here::here("app_ger_power_plant_explorer")), FALSE)
ifelse(!dir.exists(here::here("app_ger_power_plant_explorer", "code")), dir.create(here::here("app_ger_power_plant_explorer", "code")), FALSE)
ifelse(!dir.exists(here::here("app_ger_power_plant_explorer", "data")), dir.create(here::here("app_ger_power_plant_explorer", "data")), FALSE)
ifelse(!dir.exists(here::here("app_ger_power_plant_explorer", "data", "raw")), dir.create(here::here("app_ger_power_plant_explorer", "data", "raw")), FALSE)
ifelse(!dir.exists(here::here("app_ger_power_plant_explorer", "data", "processed")), dir.create(here::here("app_ger_power_plant_explorer", "data", "processed")), FALSE)
ifelse(!dir.exists(here::here("app_ger_power_plant_explorer", "data", "raw", "vg2500")), dir.create(here::here("app_ger_power_plant_explorer", "data", "raw", "vg2500")), FALSE)


path <- here::here()
files_to_copy <- list.files(path)
files_to_copy <- files_to_copy[grepl("server.R", files_to_copy, fixed = T) | grepl("ui.R", files_to_copy, fixed = T)]
file.copy(paste0(path, "/", files_to_copy), here::here("app_ger_power_plant_explorer", files_to_copy), overwrite = T)

path <- here::here("code")
files_to_copy <- list.files(path)
files_to_copy <- files_to_copy[grepl("prepare", files_to_copy, fixed = T)]
file.copy(paste0(path, "/", files_to_copy), here::here("app_ger_power_plant_explorer", "code", files_to_copy), overwrite = T)


path <- here::here("data", "raw", "vg2500")
files_to_copy <- list.files(path)
files_to_copy <- files_to_copy[!grepl(".ini", files_to_copy, fixed = T)]
file.copy(paste0(path, "/", files_to_copy), here::here("app_ger_power_plant_explorer", "data", "raw", "vg2500", files_to_copy), overwrite = T)


path <- here::here("data", "processed")
files_to_copy <- list.files(path)
files_to_copy <- files_to_copy[!grepl(".ini", files_to_copy, fixed = T) & !grepl("extend", files_to_copy, fixed = T) & !grepl("ags", files_to_copy, fixed = T)]
file.copy(paste0(path, "/", files_to_copy), here::here("app_ger_power_plant_explorer", "data", "processed", files_to_copy), overwrite = T)



# --------------------------------------------- test App locally --------------------------------
source(here::here("app_ger_power_plant_explorer", "server.R"))
source(here::here("app_ger_power_plant_explorer", "ui.R"))

shinyApp(ui, server)


# --------------------------------------------- deploy App online --------------------------------
rsconnect::deployApp(here::here("app_ger_power_plant_explorer"))
