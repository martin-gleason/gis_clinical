#me gis
library(tidyverse)
library(ggmap)
library(sf)
library(rgdal)
library(rmapshaper)
library(spdplyr)

me_df <- read_rds("medical_examiner_juvenile.RDS")


cpd_geojson <- file.path("~/Dropbox (Personal)/Coding Projects/javascript/simple_json/json/CPD districts.geojson")
cpd_districts <- readOGR(cpd_geojson) #spatial polygons data frame
cpd_districts <- cpd_districts  %>%
  mutate(region = map_chr(1:length(cpd_districts@polygons), function(i){
    cpd_districts@polygons[[i]]@ID
  }))

shapefile <- cpd_districts %>% broom::tidy()
cpd_districts_sf <- cpd_districts %>% st_as_sf()


me_df_sf <- me_df %>%
  filter(!is.na(longitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"),
           crs = "+proj=longlat +datum=WGS84")

me_df_counts <- me_df_sf %>%
  st_within(cpd_districts_sf, sparse = FALSE, prepared = TRUE)

me_df_2018_totals <- cpd_districts_sf %>%
  mutate(Count = apply(me_df_counts , 2, sum))

me_chloro <- me_df_2018_totals %>%
  ggplot() + 
  geom_sf(aes(fill = Count), size =.5, col = "white") +
  labs(title = "Shootings per District 2018") +
  scale_fill_viridis_c(name = "Count") +
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank()) 


