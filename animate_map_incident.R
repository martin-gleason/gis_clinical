#animate map
library(gganimate)
library(ggmap)
library(tidyverse)
source("me_stream_cleaning.R")
source("me_polygons.R")

#load GGMap creds
Sys.chmod("api_key.txt", mode = "0400")
con <- system.file("api_key.txt", "r")
key <- readLines("api_key.txt", n = 1, ok = TRUE)
register_google(key)

#get Chicago
chicago = get_map("Chicago, IL", zoom = 10,
                  extent = "normal")

commish_districts_sf <- commish_districts %>% 
  st_as_sf()



me <- medical_examiner %>%
  filter(!is.na(longitude)) %>%
  filter(age <=26 &
           age >= 10 &
           year(incident_date) >= 2016 &
         gunrelated == TRUE)

ggmap(chicago, maprange = TRUE) +
  geom_point(data = me, 
             aes(x = as.numeric(longitude), y = as.numeric(latitude), 
                 col = manner, shape = gender)) +
  geom_polygon(data = broom::tidy(commish_districts),
               aes(x = long, y=lat, group = group), 
               col = "black", fill = NA) +
  labs(x = "", y = "") +
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank())
  

  ggplot(me, aes(x = longitude, y = latitude, col = manner, shape = gender))
