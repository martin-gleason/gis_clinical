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

#load table
#Geocoding movied to geocode_address.R
geo_incident_all <- read_rds("geo_incident_all.RDS")
incidents <- read_rds("shootings_all.rds")

#load police Districts
cpd_geojson <- file.path("~/Dropbox (Personal)/Coding Projects/javascript/simple_json/json/CPD districts.geojson")
cpd_districts <- readOGR(cpd_geojson)

cpd_districts_sf <- cpd_districts %>% st_as_sf()

chicago = get_map("Chicago, IL")

geo_incident_cleaned <- geo_incident_all %>%
  select(id_number, home_address = address, 
         lon, lat, address_type = type, loctype)

shootings_all <- incidents %>%
  left_join(geo_incident_cleaned, by = c("id_number"))

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

#counts shootings in police districts
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

chloro_2017 %>%
  ggsave(filename = "chloro_2017.jpg", device = "jpg")

chloro_2018 %>%
  ggsave(filename = "chloro_2018.jpg", device = "jpg")
  
ggsave(filename = "chloro_map_2017_2018.jpg",
       plot = last_plot(), device = "jpg")

#save eda
ggsave("shooting_map_2017_2018.jpg", device = "jpg")


