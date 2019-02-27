#ME Polygon
library(tidyverse)
library(ggmap)
library(sf)
library(rgdal)
library(rmapshaper)
library(spdplyr)
library(leaflet)


cpd_geojson <- file.path("gis_files/CPD districts.geojson")
commish_geojson <- file.path("gis_files/Cook County Commissioner District Map.geojson")

cpd_districts <- readOGR(cpd_geojson) #spatial polygons data frame
commish_districts <- readOGR(commish_geojson)

cpd_districts <- cpd_districts  %>%
  mutate(region = map_chr(1:length(cpd_districts@polygons), function(i){
    cpd_districts@polygons[[i]]@ID
  }))

commish_districts <- commish_districts %>%
  mutate(region = map_chr(1:length(commish_districts@polygons), function(i){
    commish_districts@polygons[[i]]@ID
  }))
# 
# cpd_map <- leaflet(cpd_districts) %>%
#   addTiles() %>%
#   setView(lng = -87.7, lat = 41.9, zoom = 12) %>%
#   addPolygons(color = "black",
#               fillColor = "#D3D3D3", 
#               fillOpacity = 0.1)
# 
# 
# commish_map <- leaflet(commish_districts) %>%
#   addTiles() %>%
#   setView(lng = -87.7, lat = 41.9, zoom = 12) %>%
#   addPolygons(color = "black",
#               fillColor = "#D3D3D3", 
#               fillOpacity = 0.1)
