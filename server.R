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

#### create server ####
server <- function(input, output) {
  
  dataset <- reactive({
    get(paste0("map_and_data_", input$geo_level))
  })
  
  dataset_combined <- reactive({
    get(paste0("map_data_", input$geo_level, "_combined_all_sources"))
  })
  
  Energy <- reactive({
    if (input$source == "All") {
      dataset_combined()
    } else{
      dataset() %>% filter(EinheitenTyp == input$source)
    }
  })
  
  data_to_download <- reactive({
    if (input$source == "All") {
      dataset()
    } else{
      dataset() %>% filter(EinheitenTyp == input$source)
    }
  })
  
  dataset_region <- reactive({
    columns <- c("Solareinheit", "Windeinheit", "Biomasse", "Wasser", "Braunkohle", "Steinkohle", "Gas", "Mineralölprodukte", "Stromspeichereinheit", "Geothermie")
    
    selected_regionid <- input$map_shape_click$id
    
    # Turn the generated "." back into "-" in the state names. e.g. Nordrhein.Westfalen to Nordrhein-Westfalen
    selected_regionid <- sub(".","-",selected_regionid, fixed = TRUE)
    
    dataset <- dataset() %>% 
      filter(regionid == selected_regionid) %>% 
      filter(EinheitenTyp %in% columns)
    
    # Highlight the chosen energy type in the bar chart
    dataset$EinheitenTyp[dataset$EinheitenTyp == input$source] <- paste0(input$source, "*")
    dataset
  })
  
  coloring <- reactive({
    if (input$source == "Solareinheit"){"YlOrRd"}else{
      if (input$source == "Windeinheit"){"Blues"}else{
        if(input$source == "Braunkohle"){"Greys"}else{
          if(input$source == "Biomasse"){"Greens"}else{
            if(input$source == "Wasser"){"Blues"}else{
              if(input$source == "Geothermie"){"Oranges"}else{
                if(input$source == "Steinkohle"){"Greys"}else{
                  if(input$source == "Gas"){"Greys"}else{
                    if(input$source == "Mineralölprodukte"){"PuBuGn"}else{
                      if(input$source == "Stromspeichereinheit"){"YlOrBr"}
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  })
  
  title_legend <- reactive({
    if (input$out_var == "n"){"Number of Power Plants"}else{
      if (input$out_var == "sum"){"Power in kw(p)"} else{
        if (input$out_var == "mean"){"Power in kw(p)"}
      }
    }
  })
  
  output$title_bar_chart <- renderText({
    regionid <- input$map_shape_click$id
    if (!is.null(regionid)){
      if (input$out_var == "n"){paste("Total number of power plants in", regionid)}else{
        if (input$out_var == "sum"){paste("Total power production in", regionid)}else{
          if (input$out_var == "mean"){paste("Average power production per plant in", regionid)}
        }
      }
    }
    
    
  })
  
  output$map <- renderLeaflet({
    
    p2 <- tm_shape(Energy()) +
      tm_polygons(input$out_var, palette = coloring(), n = input$scale, title = title_legend(), 
                  id = "regionid", popup.vars = c("Value:" = input$out_var)) +
      tm_layout(legend.outside = TRUE) +
      tm_layout(frame = FALSE)
    
    tmap_leaflet(p2)
    
  })
  
  output$plot_energy_bar_chart <- renderPlot({
    if (!is.null(input$map_shape_click)) {
      ggplot(dataset_region(), aes(x = reorder(EinheitenTyp, get(input$out_var)), y = get(input$out_var))) +
        labs(y = title_legend(), x = "Energy Source") +
        geom_bar(stat="identity", fill="steelblue") + theme_minimal(base_size = 16) + 
        theme(axis.text.y = element_text(size=12, face="bold")) +
        scale_x_discrete(labels=c("Solareinheit" = "Solar",  "Windeinheit" = "Wind", 
                                  "Biomasse" = "Biomass", "Wasser" = "Water",
                                  "Braunkohle" = "Brown Coal", "Steinkohle" = "Black Coal",
                                  "Gas" = "Gas" , "Mineralölprodukte" = "Mineral Oil",
                                  "Stromspeichereinheit" = "Electricity", "Geothermie" = "Geothermal", 
                                  "Solareinheit*" = "Solar*",  "Windeinheit*" = "Wind*", 
                                  "Biomasse*" = "Biomass*", "Wasser*" = "Water*",
                                  "Braunkohle*" = "Brown Coal*", "Steinkohle*" = "Black Coal*",
                                  "Gas*" = "Gas*" , "Mineralölprodukte*" = "Mineral Oil*",
                                  "Stromspeichereinheit*" = "Electricity*", "Geothermie*" = "Geothermal*")) +
        coord_flip() 
      # scale_x_discrete(labels=c("Gas"=expression(bold(Gas))))
    }
  }, bg="transparent")
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      # data_state_solar.csv
      paste0("data_",input$geo_level,"_",input$source, ".csv")
    },
    content = function(file) {
      data_to_download <- data_to_download()
      # geometry data is too big and messsies up with the csv file. can't drop it so this is the solution
      data_to_download$geometry <- NULL
      write.csv(data_to_download, file, row.names = FALSE)
    }
  )
  
  output$plot_regional <- renderPlot({
    if (!is.null(input$map_shape_click)) {
      if (input$out_var == "n"){
        ggplot(new_data_state, aes(x=start_year,y=n, fill=EinheitenTyp))+
          geom_line(size=1.5) + geom_bar(stat="identity") +
          xlab('Year') + ylab('National total number of plants') +
          theme_minimal(base_size = 16) +
          theme(axis.text.x=element_text(angle=90, hjust=1),
                axis.title=element_text(size=18,face="bold"),
                legend.title = element_blank())
      }else{
        if (input$out_var == "sum"){
          ggplot(new_data_state, aes(x=start_year,y=sum, fill=EinheitenTyp))+
            geom_line(size=1.5) + geom_bar(stat="identity") +
            xlab('Year') + ylab('National total power production') +
            theme_minimal(base_size = 16) +
            theme(axis.text.x=element_text(angle=90, hjust=1),
                  axis.title=element_text(size=18,face="bold"),
                  legend.title = element_blank())
        } else{
          if (input$out_var == "mean"){
            ggplot(new_data_state, aes(x=start_year,y=mean, fill=EinheitenTyp))+
              geom_line(size=1.5) + geom_bar(stat="identity") +
              xlab('Year') + ylab('National average power production') +
              theme_minimal(base_size = 16) +
              theme(axis.text.x=element_text(angle=90, hjust=1),
                    axis.title=element_text(size=18,face="bold"),
                    legend.title = element_blank())
          }
        }
      }
      
    }
  }, bg="transparent")
}