# Libraries

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

# Set working directory
setwd("~/Google Drive/Insight/Challenges/MS_hackathon/interactive_map")

# Connect to Hack DB.
con = dbConnect(SQLite(), dbname = "../data/MS_hackathon.db")

# List Tables
dbListTables(con)
# List Fields in "..."
dbListFields(con, "GapMinderData")

# Query
query = dbSendQuery(con, "SELECT * FROM GapMinderData")
# Fetch query
df = dbFetch(query, n = -1)
# Clear query
dbClearResult(query)

# Read in the country file, select useful heading and turn to lower case 
world=readOGR(dsn= "~/Downloads/ne_50m_admin_0_countries/", layer="ne_50m_admin_0_countries")
names(world) = tolower(names(world))
world@data = world@data %>% select(formal_en,un_a3)
names(world@data) = c('name', 'unctry')
world@data$unctry=as.numeric(as.character((world@data$unctry)))

# Join by UN country number.
sub_df = df %>% filter(date == 2005)
world@data = left_join(world@data, sub_df)

# Simplify the population categories
world@data$population = world@data$population/1000000 %>% round(2)
# Set some bins.
mybins=c(0,10,20,50,100,500,Inf)
mypalette = colorBin(palette="YlOrBr", domain=world@data$population, na.color="transparent", bins=mybins)

# Prepare the text for the tooltip:
mytext=paste("Country: ", world@data$name,"<br/>", "Area: ", world@data$area, "<br/>", "Population: ", round(world@data$population, 2), sep="") %>%
  lapply(htmltools::HTML)

# Map plot
leaflet(world) %>% 
  addTiles()  %>% 
  setView(lat=10, lng=0 , zoom=2) %>%
  addPolygons(
    fillColor = ~mypalette(population),
    fillOpacity = 0.9, stroke=T,
    color="white", weight=0.3, dashArray = "",
    highlight = highlightOptions(
      weight = 5, color = ~colorNumeric("Blues", population)(population),
      dashArray = "", fillOpacity = 0.1, bringToFront = TRUE
    ),
    label = mytext,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "13px", direction = "auto")
    ) %>%
  addLegend(
    pal=mypalette,  values=~population,  opacity=0.9, 
    title = "Population (M)", position = "bottomleft"
  )