# Data Manipulation
library(tidyverse)
# Spatial
library(rgdal)
library(sp)
# Interactive Plots
library(leaflet)
library(shinythemes)
library(shiny)
# Database
library(DBI)
library(dbplyr)
library(RSQLite)

# Connect to Hack DB.
con = dbConnect(SQLite(), dbname = "./MS_hackathon.db")

# Query
query = dbSendQuery(con, "SELECT * FROM GapMinderData")
# Fetch query
df = dbFetch(query, n = -1)
# Clear query
dbClearResult(query)

# Read in the country shape file.
world=readOGR(dsn= "./ne_50m_admin_0_countries/", layer="ne_50m_admin_0_countries", stringsAsFactors = F)
world@data = world@data %>% select(FORMAL_EN,UN_A3) # Select formal country name and UN code.
names(world@data) = c('name', 'unctry') # Rename column names
world@data$unctry=as.numeric(world@data$unctry)
world@data$unctry[world@data$unctry==-99] = NA # Convert -99 to NA.
w_df = world@data

# Range between 0-1.
compress = function(x, lg = F, ...){
  if(lg){
    x = log(x)
    zero_one = (x - min(x, ...)) / (max(x, ...) - min(x, ...))
  } 
  else zero_one = (x - min(x, ...)) / (max(x, ...) - min(x, ...))
  return(zero_one)
}

# Button titles
buttons = list("Population","Birth Rate",
               "Life Expectancy", 
               "Life Expectancy (F)", 
               "Life Expectancy (M)",
               "Child Morality", "GDP",
               "Inflation",
               "Employment",
               "Inequality",
               "Aid Received",
               "Literacy",
               "Literacy (F)",
               "Literacy (M)",
               "Journalists Killed",
               "Cell Phone Density",
               "Corruption",
               "Democracy",
               "Murder Rate")


ui = fluidPage(
  theme = shinytheme("flatly"),
  fluidRow(tags$h1("Hackathon for Social Good Map"), align = "center"),
  sidebarPanel(
    selectInput("year","", seq(range(df$date)[1], range(df$date)[2])),
    radioButtons("sel", "", buttons), width = 3
               ),
  mainPanel(leafletOutput("map"),
            helpText("This map shows the GapMinder data standardized bewteen 0-1 in each year from 1980 to 2017."))
  
  # Year Selector
 # fluidRow(tags$h1("Hackathon for Social Good Map"), align = "center"),
 # fluidRow(selectInput("year","", seq(range(df$date)[1], range(df$date)[2]))),
 # fluidRow(
 #   column(2,radioButtons("sel", "", buttons)),
 #   column(9, leafletOutput("map")),
 #   column(1)
 #   )
)

server = function(input, output){
  # Map
  output$map = renderLeaflet({
    
    # Subset
    sub_df = df[df$date==input$year,]
    world@data = left_join(w_df, sub_df)
    
    # Organize data. Compress between 0-1 and log transform as needed.
    world@data$population = compress(world@data$population,lg=T, na.rm = T)
    world@data$annual_birth_rate_per_1000 = compress(world@data$annual_birth_rate_per_1000,lg=F, na.rm = T)
    world@data$life_exp_years = compress(world@data$life_exp_years,lg=F, na.rm = T)
    world@data$life_exp_years_f = compress(world@data$life_exp_years_f,lg=F, na.rm = T)
    world@data$life_exp_years_m = compress(world@data$life_exp_years_m,lg=F, na.rm = T)
    world@data$child_mortality = compress(world@data$child_mortality,lg=T, na.rm = T)
    world@data$gdp_usd = compress(world@data$gdp_usd,lg=T, na.rm = T)
    world@data$inflation_percent = compress(world@data$inflation_percent,lg=F, na.rm = T)
    world@data$employment = world@data$employment/100
    world@data$gini = compress(world@data$gini, F, na.rm = T)
    world@data$aid_received_pp = compress(world@data$aid_received_pp,T,na.rm=T)
    world@data$adult_lit_rate = compress(world@data$adult_lit_rate,F,na.rm=T)
    world@data$adult_lit_rate_f = compress(world@data$adult_lit_rate_f,F,na.rm=T)
    world@data$adult_lit_rate_m = compress(world@data$adult_lit_rate_m,F,na.rm=T)
    world@data$journalists_killed = compress(world@data$journalists_killed,F,na.rm=T)
    world@data$cell_phone_per_100 = compress(world@data$cell_phone_per_100,F,na.rm=T)
    world@data$corruption_index = compress(world@data$corruption_index,F,na.rm=T)
    world@data$democracy_score = compress(world@data$democracy_score,F,na.rm=T)
    world@data$murder_per_1000 = compress(world@data$murder_per_1000,T,na.rm=T)
    
    # Switch board
    DataType <- function(x) {
      switch(x,
             "Population" = world@data$population,
             "Birth Rate" = world@data$annual_birth_rate_per_1000,
             "Life Expectancy" = world@data$life_exp_years,
             "Life Expectancy (F)" = world@data$life_exp_years_f,
             "Life Expectancy (M)" = world@data$life_exp_years_m,
             "Child Morality" = world@data$child_mortality,
             "GDP" = world@data$gdp_usd,
             "Inflation" = world@data$inflation_percent,
             "Employment" = world@data$employment,
             "Inequality" = world@data$gini,
             "Aid Received" = world@data$aid_received_pp,
             "Literacy" = world@data$adult_lit_rate,
             "Literacy (F)" = world@data$adult_lit_rate_f,
             "Literacy (M)" = world@data$adult_lit_rate_m,
             "Journalists Killed" = world@data$journalists_killed,
             "Cell Phone Density" = world@data$cell_phone_per_100,
             "Corruption" = world@data$corruption_index,
             "Democracy" = world@data$democracy_score,
             "Murder Rate" = world@data$murder_per_1000
      )}
    
    # Map
    leaflet(world) %>% addTiles()  %>% 
      setView(lat=10, lng=0 , zoom=2) %>%
      addPolygons(
        fillColor = ~colorNumeric(palette = "YlOrBr",
                                  domain = c(0,1),
                                  na.color = "transparent")(DataType(input$sel)),
        fillOpacity = 0.9, stroke=T,
        color="white", weight=0.3, dashArray = "",
        highlight = highlightOptions(
          weight = 5, color = ~colorNumeric("Blues", c(0,1))(DataType(input$sel)),
          dashArray = "", fillOpacity = 0.1, bringToFront = TRUE
        ),
        label = paste("Country: ", world@data$name,"<br/>", sep="") %>% lapply(htmltools::HTML),
        labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"),
                                    textsize = "13px", direction = "auto")
      ) %>%
    addLegend(
      pal=colorNumeric(palette="YlOrBr", domain=c(0,1), na.color="transparent"),
      values=~DataType(input$sel),  opacity=0.9,
      title = "", position = "bottomleft")
  })
}

shinyApp(ui = ui, server = server)

