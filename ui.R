library("utils")
library("here")
library("shiny")
library("zip")
library("sf")
library("tmap")
library("tmaptools")
library("ggplot2")
library("dplyr")
library("shinydashboard")
library("leaflet")

map_data_state_combined_all_sources <- readRDS("data/processed/map_data_state_combined_all_sources.rds")
map_data_county_combined_all_sources <- readRDS("data/processed/map_data_county_combined_all_sources.rds")
map_and_data_county <- readRDS("data/processed/map_and_data_county.rds")
map_and_data_state <- readRDS("data/processed/map_and_data_state.rds")
data_state_yearly <- read.csv2("data/processed/data_state_yearly.csv", row.names = NULL, encoding = "UTF-8", stringsAsFactors = FALSE)
new_data_state <- subset(data_state_yearly, start_year >= "2000")

#####create ui
ui <- dashboardPage(
  dashboardHeader(title = "Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Storyline", tabName = "storyline", icon = icon("dashboard")),
      menuItem("Data", tabName = "data_explorer", icon = icon("th")),
      menuItem("Reference", tabName = "reference", icon = icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "storyline",
              h2("Do rich regions use more renewable energy in Germany? (for example)"),
              div(class = "text",
                  p("Because we do not have a story yet,", tags$b("the content is left blank intentionally.")),
                  p("And I just put these sentences", tags$em("to test the codes."))
              )
      ),
      
      # Second tab content
      tabItem(tabName = "data_explorer",
              fluidRow(
                column(width = 4,
                       fluidRow(
                         column(width = 12,
                                h3("German Power Plants Explorer", align = "center"),
                                #titlePanel("German Power Plants Explorer"),
                                sidebarPanel(width = 12,
                                             selectInput('source', 'Energy Source', c("All" = "All", "Solar Energy" = "Solareinheit", "Wind Energy" = "Windeinheit", 
                                                                                      "Biomass Energy" = "Biomasse", "Water Energy" = "Wasser",
                                                                                      "Brown Coal Energy" = "Braunkohle", "Black Coal Energy" = "Steinkohle",
                                                                                      "Gas Energy" = "Gas", "Mineral Oil Energy" = "Mineralölprodukte",
                                                                                      "Electrical Energy" = "Stromspeichereinheit", "Geothermal Energy" = "Geothermie")),
                                             selectInput('geo_level', 'Geographical Level', c("State" = "state", "County" = "county")),
                                             selectInput('out_var', 'Output Variable', c("Total number of power plants" = "n", 
                                                                                         "Total power production" = "sum", 
                                                                                         "Average power production per plant" = "mean" )),
                                             sliderInput("scale", "Rough Number of Legend Classes",
                                                         min = 2, max = 10, value = 6),
                                             
                                             # Button
                                             downloadButton("downloadData", "Download Data")
                                )
                         )
                       )
                       
                ),
                column(width = 8,
                       fluidRow(
                         column(width = 12,
                                h3("Germany in geographical zones"),
                                leafletOutput('map')
                         )
                       ),
                       fluidRow(
                         column(width = 12,
                                h3(textOutput("title_bar_chart")),
                                plotOutput('plot_energy_bar_chart'),
                                plotOutput('plot_regional')
                         )
                       )
                )
              )
      ),
      
      # Third tab content
      tabItem(tabName = "reference",
              h2("Reference"),
              div(class = "list",
                  tags$ul(
                    tags$li(tags$b("Data"), ": German power plants raw data is downloaded from official register Marktstammdatenregister through following link:", tags$a(href="https://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/Unternehmen_Institutionen/ErneuerbareEnergien/ZahlenDatenInformationen/VOeFF_Registerdaten/DatenAb310119.zip", "https://www.bundesnetzagentur.de/SharedDocs/Downloads/DE/Sachgebiete/Energie/", tags$br("Unternehmen_Institutionen/ErneuerbareEnergien/ZahlenDatenInformationen/VOeFF_Registerdaten/DatenAb310119.zip"))),
                    p("The register includes the potential production of power plants in Germany including renewables like wind, solar and biomass as well as coal and nuclear. The source provides more than 100 variables for various purposes."),
                    tags$li(tags$b("License"), ": What should we write about data license? Should we translate some relevant sections of the data usage policy of Bundesnetzagentur?")
                  )
              )
      )
    )
  )
)