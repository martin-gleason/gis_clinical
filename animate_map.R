#animate map
library(gganimate)
source("me_stream_cleaning.R")
source("me_polygons.R")

commish_districts_sf <- commish_districts %>% 
  st_as_sf()


me_sf_commish_counts <- me_sf %>%
  st_within(commish_districts_sf, sparse = FALSE, prepared = TRUE)

me_counts_commish <- commish_districts_sf  %>%
  mutate(Count = apply(me_sf_commish_counts, 2, sum))


test <- commish_districts_sf  %>%
  mutate(Count = apply(me_sf_commish_counts, 2, sum))

me_counts_commish %>%
  mutate(created_at = )
ggplot() +
  geom_sf(aes(fill = Count), size =.5, col = "white") +
  labs(title = "Shootings per District: 2017") +
  scale_fill_viridis_c(name = "Count") +
  theme(panel.background = element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank())

