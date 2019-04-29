# Load packages
library(rgdal)
library(sp)
library(leaflet)
library(shinythemes)
library(shiny)

# Set working directory
setwd("~/Google Drive/Insight/Challenges/MS_hackathon/interactive_map")

# Read in the country file.
world_spdf=readOGR(dsn=getwd(), layer="TM_WORLD_BORDERS_SIMPL-0.3")
names(world_spdf) = tolower(names(world_spdf))

# Modify data
world_spdf@data$pop2005[world_spdf@data$pop2005 == 0] = NA
world_spdf@data$pop2005 = as.numeric(as.character(world_spdf@data$pop2005)) / 1000000 %>% round(2)

# Prepare the text for the tooltip:
mytext=paste("Country: ", world_spdf@data$name,"<br/>", "Area: ", world_spdf@data$area, "<br/>", "Population: ", round(world_spdf@data$pop2005, 2), sep="") %>%
  lapply(htmltools::HTML)

DataType <- function(x) {
  switch(x,
         "Population" = world_spdf@data$pop2005,
         "Area" = world_spdf@data$area,
         "Region" = world_spdf@data$region,
         "Sub-Region" = world_spdf@data$subregion
  )}


ui = fluidPage(
  fluidRow(tags$h1("Hackathon for Social Good Map"), align = "center"),
  fluidRow(
    column(2,radioButtons("sel", "",
                 list("Population","Area","Region","Sub-Region"))),
    column(9, leafletOutput("map")),
    column(1)
  )
)

server = function(input, output) {
  output$map = renderLeaflet({
    # Create a color palette for the map:
    if(input$sel == "Population") {
      mybins=c(0,10,20,50,100,500,Inf)
      mypalette = colorBin(palette="YlOrBr", domain=DataType(input$sel),
                           na.color="transparent", bins = mybins)
    } else {
      mypalette = colorNumeric("YlOrBr", DataType(input$sel))
    }
    hghlght = colorNumeric("Blues", DataType(input$sel))(DataType(input$sel))
    
    # Map
    leaflet(world_spdf) %>% 
      addTiles()  %>% 
      setView(lat=10, lng=0 , zoom=2) %>%
      addPolygons(
        fillColor = ~mypalette(DataType(input$sel)),
        fillOpacity = 0.9, stroke=T,
        color="white", weight=0.3, dashArray = "",
        highlight = highlightOptions(
          weight = 5, color = hghlght,
          dashArray = "", fillOpacity = 0.1, bringToFront = TRUE
        ),
        label = mytext,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "13px", direction = "auto")
      ) %>% 
      addLegend(
        pal=mypalette,  values=DataType(input$sel),  opacity=0.9, 
        title = "", position = "bottomleft"
      )
  })
}

shinyApp(ui = ui, server = server)