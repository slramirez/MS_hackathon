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

# For local use.
#setwd("~/Google Drive/Insight/Challenges/MS_hackathon/interactive_map")

# Connect to Hack DB.
con = dbConnect(SQLite(), dbname = "./MS_hackathon.db")

# Query
query = dbSendQuery(con, "SELECT * 
                    FROM GapMinderData
                    LEFT JOIN CIRI_Cluster ON GapMinderData.unctry = CIRI_Cluster.unctry AND
                    GapMinderData.date = CIRI_Cluster.year 
                    WHERE date > 2012")
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

server = function(input, output){
  # Create Map
  output$map = renderLeaflet({
    
    # Subset Gapminder Data
    sub_df = df[df$date==input$year,]
    world@data = left_join(w_df, sub_df)
    
    # Organize data. Compress between 0-1 and log transform as needed.
    world@data$population = compress(world@data$population, lg=T, na.rm = T)
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
    
    # Wink out unselected clusters.
    #world@data[!(world@data$class %in% as.numeric(input$clusters)),"class"] = NA
    world@data[!(world@data$class %in% as.numeric(input$clusters)),5:ncol(world@data)] = NA
    #if(input$clusters == "2") browser()
    # Switch board (selector is linked to column in subset data)
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
    
    if(input$sel=="Population"){
      myPal = colorBin(palette = "YlOrBr", domain = c(0,1), na.color = "#282F4480",
                       bins = c(0,.4,.6,.8,.9,1), alpha = F)(DataType(input$sel))
    }
    else{
      myPal = colorNumeric(palette = "YlOrBr", domain = c(0,1), na.color = "#282F4480",
                           alpha = F)(DataType(input$sel))
    }
    # Map
    leaflet(world) %>% addTiles()  %>% 
      setView(lat=10, lng=0 , zoom=2) %>%
      addPolygons(
        fillColor = ~myPal,
        fillOpacity = 0.9, stroke=T,
        color="white", weight=0.3, dashArray = "",
        highlight = highlightOptions(
          weight = 5, color = ~colorNumeric("Blues", c(0,1))(DataType(input$sel)),
          dashArray = "", fillOpacity = 0.1, bringToFront = TRUE
        ),
        label = paste("Country: ", world@data$name,"<br/>",
                      "Disappearance: ", world@data$disap,"<br/>",
                      "Extrajudicial Killing: ", world@data$kill,"<br/>",
                      "Torture: ", world@data$tort,"<br/>",
                      "Political Imprisonment: ", world@data$polpris,"<br/>",
                      "Freedom of Assembly: ", world@data$assn,"<br/>",
                      "Freedom of Foreign Movement: ", world@data$formov,"<br/>",
                      "Freedom of Domestic Movement: ", world@data$dommov,"<br/>",
                      "Freedom of Speech: ", world@data$speech,"<br/>",
                      "Electoral Self Determination: ", world@data$elecsd,"<br/>",
                      "Electoral Self Determination: ", world@data$elecsd,"<br/>",
                      "Freedom of Religion: ", world@data$new_relfre,"<br/>",
                      "Workers Rights: ", world@data$worker,"<br/>",
                      "Women's Economic Rights: ", world@data$wecon,"<br/>",
                      "Women's Political Rights: ", world@data$wopol,"<br/>",
                      "Independence of the Judiciary: ", world@data$injud,"<br/>",
                      sep="") %>% 
          lapply(htmltools::HTML),
        labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"),
                                    textsize = "13px", direction = "auto")
      ) %>%
    addLegend(
      pal=colorNumeric(palette="YlOrBr", domain=c(0,1), na.color="transparent", reverse = T),
      values=~DataType(input$sel), opacity=0.9,
      title = "", position = "bottomleft", 
      labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE)))
  })
  output$clust_img = renderImage({
      return(list(
        src = paste("./cluster_imgs/",input$year,".png",sep=""),
        contentType = "image/png",
        alt = "Analysis Clusters",
        width = "100%"))
  }, deleteFile = F)
  output$word_map_neg = renderImage({
    return(list(
      src=paste("./Cluster_Word_Clouds/",input$year,".0_",input$clusters[1],".0.png", sep = ""),
      contentType = "image/png",
      alt = "Cluster Word Cloud",
      width = "100%"
    ))
  }, deleteFile = F)
  output$word_map_pos = renderImage({
    return(list(
      src=paste("./Cluster_Word_Clouds/Good News Filtered/",input$year,".0_",input$clusters[1],".0.png", sep = ""),
      contentType = "image/png",
      alt = "Cluster Word Cloud",
      width = "100%"
    ))
  }, deleteFile = F)
}

#paste("./Cluster_Word_Clouds/Good News Filtered/2013.0_1.0.png")

ui = fluidPage(
  # Theme
  theme = shinytheme("flatly"),
  # Title
  fluidRow(tags$h1("Global Patterns in Human Rights"),
           tags$h3("Seattle Data Science Insight Fellows"),
           tags$p("Priscilla Addison, Tyler Blair, Kyle Chezik, Colin Dietrich, Stephanie Lee, Marie Salmi, Gareth Walker"), align = "center"),
  fluidRow(tags$hr(style="border: 1px solid black")),
  # Sidebar Selector Panel
  sidebarPanel(
    checkboxGroupInput(inputId = "clusters", label = "Human Rights Country Clusters",
                       choices = list(1,2,3,4,5,6,7,8), inline = T, selected = 1),
    
    selectInput("year", "Year", choices = list(2013,2014,2015)),
    
    radioButtons("sel", "GapMinder Data", buttons, inline = T), width = 3),
  # Map
  mainPanel(tags$h4("Country GapMinder Data Filtered by Human Rights Clusters"),
            leafletOutput("map"),
            helpText("This map shows the GapMinder data standardized bewteen 0-1 in each year from 1980 to 2017 for countries with data. Smaller values indicate relatively lower values of the chosen variable. Locations either not in the chosen cluster or without known data in the given year are dark but relative values consider all GapMinder data in the chosen year across clusters.")),
  # Word Map Image
  fluidRow(column(3, tags$h4("Negative Cluster Word Cloud"),
                  tags$p("This word cloud represents the dominant words in US State Department Reports indicating poor human rights and low CIRI scores in the given cluster."),
                  imageOutput("word_map_neg"),
           tags$h4("Positive Cluster Word Cloud"),
                  tags$p("This word cloud represents the dominant words in US State Department Reports indicating good human rights and high CIRI scores in the given cluster."),
                  imageOutput("word_map_pos")),
  column(9,tags$h4("Human Rights Cluster Analysis"),
         tags$p("Gaussian Mixture Model Clustering of countries by human rights conditions given CIRI scores in a given year. Clusters encompassing a greater area include countries with better human rights conditions."),
         imageOutput("clust_img")))
)


shinyApp(ui = ui, server = server)

