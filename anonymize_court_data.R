#geocoding_ally
library(tidyverse)
library(lubridate)
library(leaflet)
library(ggmap)
library(spdplyr)
library(geojsonio)
library(rgdal)
library(rmapshaper)
library(sf)

#GGMap
Sys.chmod("api_key.txt", mode = "0400")
con <- system.file("api_key.txt", "r")
key <- readLines("api_key.txt", n = 1, ok = TRUE)
register_google(key)

court_data <- read_rds("shootings_all.rds")

court_data <- court_data %>%
  mutate_geocode(home_address) 

court_data <- court_data %>%
  filter(!is.na(incident_date)) %>%
  select(-home_address)

write_rds(court_data, "anon_court_data.RDS")



