#GIS Loading
library(tidyverse)
library(lubridate)
library(leaflet)
library(ggmap)
library(spdplyr)
library(geojsonio)
library(rgdal)
library(rmapshaper)
library(sf)
library(here)

#load table
#Geocoding moved to geocode_address.R
shootings_all <- read_rds("anon_court_data.RDS")

#load police Districts
cpd_geojson <- file.path("gis_files/CPD districts.geojson")
cpd_districts <- readOGR(cpd_geojson)

cpd_districts_sf <- cpd_districts %>% st_as_sf()

con <- file.path("key.txt")
key <- readLines(con, n = 1, ok = TRUE)
register_google(key)

x <- here("key.txt")
readLines(x)


Sys.chmod("new_api_key.txt", mode = "0400")
api_key <- system.file("key.txt")
#google api key for getting chicago map

key <- readLines(con = api_key, n = 1, ok = TRUE)
register_google(key)

chicago = get_map("Chicago, IL")

shooting_eda_map <- chicago %>%
  ggmap() +
  geom_point(data = shootings_all, 
             aes(x = lon, y = lat, 
                 col = as.factor(year(incident_date))), alpha = 0.5) +
  labs(col = "Calendar Year")

shooting_eda_map + geom_polygon(data = broom::tidy(cpd_districts),
             aes(x = long, y=lat, group = group, col = "black"), fill = NA)


shooting_map_chlor <- chicago %>%
  ggmap() +
  geom_polygon(data = broom::tidy(cpd_districts),
                 aes(x = long, y=lat, group = group), 
               col = "black", fill = NA) +
  stat_sf(data = shootings_all,
              aes(fill = as.factor(year(incident_date))))


shootings_all <- shootings_all %>%
  st_as_sf(coords = c("lon", "lat"),
           crs = "+proj=longlat +datum=WGS84")

#https://stackoverflow.com/questions/45891034/create-choropleth-map-from-coordinate-points

#counts cta stops in police districts
shootings_count_2017<- shootings_all %>%
  filter(year(incident_date) == 2017) %>%
  st_within(cpd_districts_sf, sparse = FALSE, prepared = TRUE)

shootings_count <- shootings_all %>%
  st_within(cpd_districts_sf, sparse = FALSE, prepared = TRUE)

count_2017 <- shootings_all %>%
  filter(year(incident_date) == 2017) %>%
  st_as_sf(coords = c("lon", "lat"),
           crs = "+proj=longlat +datum=WGS84")

count_2018 <- shootings_all %>%
  filter(year(incident_date) == 2018) %>%
  st_as_sf(coords = c("lon", "lat"),
           crs = "+proj=longlat +datum=WGS84")


shooting_count_2018 <- shootings_all %>%
  filter(year(incident_date) == 2018) %>%
  st_within(cpd_districts_sf, sparse = FALSE, prepared = TRUE)

shootings_all_df <- cpd_districts_sf %>%
  mutate(Count = apply(shootings_count, 2, sum))

shootings_2018_df <- cpd_districts_sf %>%
  mutate(Count = apply(shooting_count_2018, 2, sum))

shootings_count_2017_df <- cpd_districts_sf %>%
  mutate(Count = apply(shootings_count_2017, 2, sum))

shootings_count_2018_df <- cpd_districts_sf %>%
  mutate(Count = apply(shooting_count_2018, 2, sum))


chloro_shooting <- shootings_all_df %>%
  ggplot() +
  geom_sf(aes(fill = Count), size =.5, col = "white") +
  scale_fill_viridis_c(name = "Shootings per District")

chloro_2017 <- shootings_count_2017_df %>%
  ggplot() +
  geom_sf(aes(fill = Count), size =.5, col = "white") +
  labs(title = "Shootings per District: 2017") +
  scale_fill_viridis_c(name = "Count") +
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank()) 
  
chloro_2018 <- shootings_count_2018_df %>%
  ggplot() + 
  geom_sf(aes(fill = Count), size =.5, col = "white") +
  labs(title = "Shootings per District 2018") +
  scale_fill_viridis_c(name = "Count") +
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank()) 

