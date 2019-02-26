#load CSV of County Cororner
library(tidyverse)
library(readr)
library(lubridate)

deaths <- file.path("/Users/marty/Downloads/Medical_Examiner_Case_Archive.csv")

medical_examiner <- read_csv(deaths)


medical_examiner <- medical_examiner %>%
  mutate(source = "Medical Examiner")

medical_examiner <- medical_examiner %>%
  mutate(Race = if_else(Latino, paste0(Race, " Latino"), Race))

min(medical_examiner$`Date of Incident`)
medical_examiner$`Date of Incident` <- as.Date(medical_examiner$`Date of Death`, format = "%m/%d/%Y")
medical_examiner$`Date of Death` <- as.Date(medical_examiner$`Date of Death`, format = "%m/%d/%Y")
medical_examiner$Gender <- as.factor(medical_examiner$Gender)
medical_examiner$Race <- as.factor(medical_examiner$Race)
medical_examiner$`Manner of Death` <- medical_examiner$`Manner of Death` %>%
  replace_na("UNDETERMINED")
medical_examiner$`Manner of Death` <- as.factor(medical_examiner$`Manner of Death`)

medical_examiner$`Primary Cause` <- as.factor(medical_examiner$`Primary Cause`)



medical_examiner_headers <- names(medical_examiner)

medical_examiner %>%
  filter(Latino == TRUE) %>% 
  select(Race) %>%
  unique()

# limit variables
medical_examiner_juvenile <- medical_examiner %>%
  filter(Age <=18 & is.na(`Opioid Related`) & `Gun Related` == TRUE) %>%
  filter(year(`Date of Incident`) >= 2017)  %>%
  select(c(2:6, 8:9, 15:18, 20, 23:26))

medical_examiner %>% 
  filter(Age <=18) %>%
  ggplot(aes(x = Race, fill = `Manner of Death`)) + 
  geom_histogram(stat = "count", position = "dodge") +
  facet_wrap( ~ Gender) +
  coord_flip()

medical_examiner %>%
  group_by(`Date of Incident`) %>%
  ggplot(aes(x = `Date of Incident`)) + geom_line(aes(color = Race), stat = "count") +
  facet_wrap(~ Gender)

write_rds(medical_examiner_juvenile, "medical_examiner_juvenile.RDS")


medical_examiner_juvenile %>%
  group_by(`Date of Incident`) %>%
  ggplot(aes(x = `Date of Incident`)) + geom_line(aes(color = Gender), stat = "count") +
  facet_wrap(~ Race)

