#geocode addresses
library(ggmap)
library(tidyverse)

#GGMap
Sys.chmod("api_key.txt", mode = "0400")
con <- system.file("api_key.txt", "r")
key <- readLines("api_key.txt", n = 1, ok = TRUE)
register_google(key)


court <- c(lat = 41.86767, lon = -87.68108)

incidents <- read_csv("geocoding_shootings_all.csv")

incidents <- incidents %>%
  mutate(incident_year = year(incident_date))

geo_incident <- incidents %>%
  select(id_number, incident_date, home_address)

geo_incident_all <- geo_incident %>%
  mutate_geocode(home_address, output = "more")


write_rds(geo_incident_all, path = "geo_incident_all.RDS")
