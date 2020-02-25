# ------------------------------------- ATTENTION: THIS FILE WILL GET SOURCED ---------------------
# ----------------------------------------------- installing, loading libraries -------------------
# library("utils")

packages <- c("here", "shiny", "zip", "sf", "tmap", "tmaptools", "ggplot2", "dplyr", "shinydashboard", "leaflet")

### install if necessary
if (F){# just run by hand to limit time that sourcing takes
  lapply(packages, 
         function(x)
         {
           if(!(x %in% installed.packages()) | x %in% old.packages())
           {
             install.packages(x)  
           }
         })
}

lapply(packages, require, character.only = T)

# ---------------------------------------------- D E F I N I T I O N S --------------------------
#rm(list=ls(all=TRUE))
options(scipen = 999) # no scientific numbering
file_ger_shape <- here("data", "raw", "vg2500", "vg2500_sta.shp")
file_ger_shape_state <- here("data", "raw", "vg2500", "vg2500_lan.shp")
file_ger_shape_county <- here("data", "raw", "vg2500", "vg2500_krs.shp")


# ------------------------------------------- load data and prepare data ---------------------------
## read state and county data files
data_state <- read.csv2(here("data", "processed", paste0("data_state", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
data_state_combined_all_sources <- read.csv2(here("data", "processed", paste0("data_state_combined_all_sources", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
data_state_yearly <- read.csv2(here("data", "processed", paste0("data_state_yearly", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
data_state_yearly_combined_all_sources <- read.csv2(here("data", "processed", paste0("data_state_yearly_combined_all_sources", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
#data_state_yearly_extended <- read.csv2(here("data", "processed", paste0("data_state_yearly_extended", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
# -> not needed in current version

data_county <- read.csv2(here("data", "processed", paste0("data_county", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
data_county_combined_all_sources <- read.csv2(here("data", "processed", paste0("data_county_combined_all_sources", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
data_county_yearly <- read.csv2(here("data", "processed", paste0("data_county_yearly", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
data_county_yearly_combined_all_sources <- read.csv2(here("data", "processed", paste0("data_county_yearly_combined_all_sources", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
#data_county_yearly_extended <- read.csv2(here("data", "processed", paste0("data_county_yearly_extended", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
# -> not needed in current version

#data_offshore <- read.csv2(here("data", "processed", paste0("data_offshore", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
# -> not needed in current version


# ---------------------------------- load data: First Story on Solar and Income --------------------
data_county_solar_income_2015 <- read.csv2(here("data", "processed", paste0("data_county_solar_income_2015", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
data_state_solar_income_2015 <- read.csv2(here("data", "processed", paste0("data_state_solar_income_2015", ".csv")), row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)

## read all shape files
ger_shape <- st_read(file_ger_shape, options = "ENCODING=UTF-8", stringsAsFactors = FALSE)
ger_shape_state <- st_read(file_ger_shape_state, options = "ENCODING=UTF-8", stringsAsFactors = FALSE)
ger_shape_county <- st_read(file_ger_shape_county, options = "ENCODING=UTF-8", stringsAsFactors = FALSE)


# some shapes need multiple entries of geometry
# these duplicated entries will multiply the amount of facilities and power -> needs correction if merged too early
# federal level: duplicate found
#ger_shape$GEN[duplicated(ger_shape$GEN)]

# state-level: no duplicates
#ger_shape_state$GEN[duplicated(ger_shape_state$GEN)]

# county-level: some duplicates (with different geometry information: adding later to one county)
#ger_shape_county$GEN[duplicated(ger_shape_county$GEN)]
# numbers of counties
#nrow(ger_shape_county) - length(ger_shape_county$GEN[duplicated(ger_shape_county$GEN)])

## prepare merge
names(ger_shape_state)[names(ger_shape_state) == "GEN"] <- "Bundesland"
names(ger_shape_county)[names(ger_shape_county) == "GEN"] <- "Landkreis"

names(ger_shape_state)[names(ger_shape_state) == "RS"] <- "ags"
names(ger_shape_county)[names(ger_shape_county) == "RS"] <- "ags"

ger_shape_county$ags <- as.numeric(ger_shape_county$ags)
ger_shape_state$ags <- as.numeric(ger_shape_state$ags)

# -----------------------------------------------------------------------------------------------
#### merge shape file after aggregation ####
## general maps for data exploration
map_data_state <- left_join(ger_shape_state, data_state, by = c("ags" = "ags_federal_state"))
rm(data_state)
map_data_state_combined_all_sources <- left_join(ger_shape_state, data_state_combined_all_sources, by = c("ags" = "ags_federal_state"))
rm(data_state_combined_all_sources)
map_data_county <- left_join(ger_shape_county, data_county, by = c("ags" = "ags_county"))
rm(data_county)
map_data_county_combined_all_sources <- left_join(ger_shape_county, data_county_combined_all_sources, by = c("ags" = "ags_county"))
rm(data_county_combined_all_sources)

# yearly datasets
map_data_state_yearly <- left_join(ger_shape_state, data_state_yearly, by = c("ags" = "ags_federal_state"))
rm(data_state_yearly)
map_data_state_yearly_combined_all_sources <- left_join(ger_shape_state, data_state_yearly_combined_all_sources, by = c("ags" = "ags_federal_state"))
rm(data_state_yearly_combined_all_sources)

#map_data_county_yearly <- left_join(ger_shape_county, data_county_yearly, by = c("ags" = "ags_county"))
# -> merged later: would blow the data limit of Shiny App
map_data_county_yearly_combined_all_sources <- left_join(ger_shape_county, data_county_yearly_combined_all_sources, by = c("ags" = "ags_county"))
rm(data_county_yearly_combined_all_sources)


# Lage "Windkraft auf See" dropped

# create region IDs
names(map_data_state)[names(map_data_state) == "Bundesland"] <- "regionid"
names(map_data_state_combined_all_sources)[names(map_data_state_combined_all_sources) == "Bundesland"] <- "regionid"
names(map_data_county)[names(map_data_county) == "Landkreis"] <- "regionid" # name leads to NA entries
names(map_data_county_combined_all_sources)[names(map_data_county_combined_all_sources) == "name"] <- "regionid"

names(map_data_state_yearly)[names(map_data_state_yearly) == "Bundesland"] <- "regionid"
names(map_data_state_yearly_combined_all_sources)[names(map_data_state_yearly_combined_all_sources) == "Bundesland"] <- "regionid"
#names(map_data_county_yearly)[names(map_data_county_yearly) == "name"] <- "regionid"
names(map_data_county_yearly_combined_all_sources)[names(map_data_county_yearly_combined_all_sources) == "Landkreis"] <- "regionid" # name leads to NA entries


## checked earlier: missing ags_federal_state dropped
#table(data_state$ags_federal_state, useNA = "always")
#data_state[is.na(data_state$ags_federal_state),]
#map_data_state_combined_all_sources[is.na(map_data_state_combined_all_sources$ags_federal_state),]
#map_data_state_yearly_combined_all_sources[is.na(map_data_state_yearly_combined_all_sources$ags_federal_state),]

# related to offshore (always if ags_federal_state is missing)

## ...

# ---------------------------------- performance improvement: break down files to energy type ----
# ------------------ map data state ----
## stock
list_types <- unique(map_data_state$EinheitenTyp)
for (i in list_types)
{
  assign(paste0(deparse(substitute(map_data_state)), "_", i), map_data_state %>%
                            filter(EinheitenTyp == i))
}

## no removal of complete dataset since the complete one is part of graph 3
# rm(map_data_state)

## flow
list_types <- unique(map_data_state_yearly$EinheitenTyp)
for (i in list_types)
{
  assign(paste0(deparse(substitute(map_data_state_yearly)), "_", i), map_data_state_yearly %>%
           filter(EinheitenTyp == i))
}

rm(map_data_state_yearly)

# ------------------ map data county ----
## stock
list_types <- unique(map_data_county$EinheitenTyp)
for (i in list_types)
{
  assign(paste0(deparse(substitute(map_data_county)), "_", i), map_data_county %>%
           filter(EinheitenTyp == i))
}

## no removal of complete dataset since the complete one is part of graph 3
# rm(map_data_county)

## flow
#list_types <- unique(map_data_county_yearly$EinheitenTyp)
#for (i in list_types)
#{
#  assign(paste0(deparse(substitute(map_data_county_yearly)), "_", i), map_data_county_yearly %>%
#           filter(EinheitenTyp == i))
#}
## here: do this for data_county and merge map data later (reducing data storage)
list_types <- unique(data_county_yearly$EinheitenTyp)
for (i in list_types)
{
  df <- data_county_yearly %>%
    filter(EinheitenTyp == i)
  
  # delete extracted information from large data file on the run
  data_county_yearly <- data_county_yearly %>%
    filter(EinheitenTyp != i)
  
  # join map for this part
  df <- left_join(ger_shape_county, df, by = c("ags" = "ags_county"))
  
  names(df)[names(df) == "Landkreis"] <- "regionid"
  
  assign(paste0(deparse(substitute(map_data_county_yearly)), "_", i), df)
  
}
rm(data_county_yearly)
rm(df)
