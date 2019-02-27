#socrata link
library(tidyverse)
library(lubridate)
require(RSocrata)

medical_examiner <- read.socrata("https://datacatalog.cookcountyil.gov/resource/xswi-76cy.json")


medical_examiner <- medical_examiner %>%
  mutate(source = "Medical Examiner")

me_original <- medical_examiner

medical_examiner$latino <- as.logical(medical_examiner$latino)
medical_examiner <- medical_examiner %>%
  mutate(race = if_else(latino, paste0(race, " Latino"), race))

medical_examiner <- medical_examiner %>%
  mutate(race = if_else(race == "Other Latino", paste0("Latino"), race))

medical_examiner$gender <- as.factor(medical_examiner$gender)
medical_examiner$race <- as.factor(medical_examiner$race)
medical_examiner$manner <- medical_examiner$manner %>%
  replace_na("UNDETERMINED")
medical_examiner$manner <- as.factor(medical_examiner$manner)

medical_examiner$primarycause <- as.factor(medical_examiner$primarycause)

medical_examiner$age <- as.numeric(medical_examiner$age)

medical_examiner <- medical_examiner %>%
  select(c(1, 4:5, 7, 9, 11, 12, 15:19, 20:26))

medical_examiner$race %>%
  unique()

gun_death_2017_2018 <- medical_examiner %>%
  filter(year(death_date) >= 2017 & gunrelated == TRUE & age <= 26)

gun_death_2017_2018 %>%
  ggplot(aes(x = as.factor(year(death_date)), group = race,
             fill = race)) + geom_bar(stat = "count", position = "dodge") + 
  facet_wrap( ~ manner)

gun_death_group <- gun_death_2017_2018 %>% group_by(race, manner, gender)

gun_death_group %>% summarize(n = n()) 

