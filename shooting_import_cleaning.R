#Shooting Data: v1. Take the spreadsheet, clean it and put it into tidy long or tidy-wide formats for additional analysis.

#importing and cleaning
library(tidyverse)
library(lubridate)
library(readxl)
library(chron)
library(ggmap)
source(file.path("../scripts/date_conversions.R"))

print("Load Spreadsheet")
#pick the workbook
file_path <- file.path("/Users/marty/Downloads/2017_2018_shooting_DATASET.xlsx")

#take workbook and divide into seperate sheets
shooting_2017 <- read_xlsx(file_path, sheet = 1)
shooting_diversion <- read_xlsx(file_path, sheet = 5)
shooting_2018 <- read_xlsx(file_path, sheet = 7)

#remove color legend
shooting_2017 <- shooting_2017[1:178, ]

#rename columns to remove spaces, capitals
shooting_2017 <- shooting_2017 %>%
  select(incident_date = `DATE of incident`, first_name = `FIRST NAME`,
         last_name = `LAST NAME`, dob = BIRTHDATE, type = TYPE,
         police_district_arrest = DISTRICT, gender = GENDER,
         race = RACE, ssl = SSL, finding = `FINDING THAT LED TO CURRENT PROBATION ORDER`,
         gang = GANG, calendar = CALENDAR, dcpo = DCPO, spo = SPO, po = PO,
         home_address = `HOME ADDRESS (REPORTED IN JEMS)`, zipcode = `zip code`,
         police_district_residence = `Pol. Dist. Residence`, 
         arrests_prior = `Total JUVENILE Arrests (PRIOR TO INCIDENT)`,
         number_petitions = `# of Petitions`, petitions_with_findings = `# of PETITIONS W/ A Finding`,
         offense_type = `OFFENSE TYPE`, jjor_findings = `Other JJOR findings (all petitions)`,
         pending_charges = `Pending petition (charges)`, 
         ips_order = `PREVIOUS IPS ORDER`, 
         IDJJ_bring_back = `IDJJ BB`, idjj_commitment = `Previous IDJJ Commitments`, 
         rmis_JTDC_holds_bedstay = `RMIS- # of JTDC holds W. BEDSTAY`, rmis_bed_days = `RMIS - Total # of bed days`,
         total_probation_orders = `# of Prob/Supv Orders`, technical_vops = `# of Tech VOPs`, 
         vop_findings = `# of VOP Findings`, 
         initial_yasi_risk = `CASEWORKS- overall YASI risk score when they came to us`,
         number_interventions = INTERVENTIONS, interventions = `list interventions`
         ) %>%
  mutate(year = year(incident_date))

shooting_2018 <- shooting_2018 %>%
  select(incident_date = `DATE of incident`,
         first_name = `FIRST NAME`, last_name = `LAST NAME`, dob = BIRTHDATE, type = TYPE,
         police_district_arrest = DISTRICT, gender = GENDER,
         race = RACE, ssl = SSL, finding = `FINDING THAT LED TO CURRENT PROBATION ORDER`,
         gang = GANG, calendar = CALENDAR, dcpo = DCPO, spo = SPO, po = PO,
         home_address = `HOME ADDRESS (REPORTED IN JEMS)`, zipcode = `zip code`,
         police_district_residence = `Pol. Dist. Residence`, 
         arrests_prior = `Total JUVENILE Arrests (PRIOR TO INCIDENT)`,
         number_petitions = `# of Petitions`, petitions_with_findings = `# of PETITIONS W/ A Finding`,
         offense_type = `OFFENSE TYPE`, jjor_findings = `Other JJOR findings (all petitions)`,
         pending_charges = `Pending petition (charges)`, 
         ips_order = `PREVIOUS IPS ORDER`, 
         IDJJ_bring_back = `IDJJ BB`, idjj_commitment = `Previous IDJJ Commitments`, 
         rmis_JTDC_holds_bedstay = `RMIS- # of JTDC holds W. BEDSTAY`, rmis_bed_days = `RMIS - Total # of bed days`,
         total_probation_orders = `# of Prob/Supv Orders`, technical_vops = `# of Tech VOPs`, 
         vop_findings = `# of VOP Findings`, 
         initial_yasi_risk = `CASEWORKS- overall YASI risk score when they came to us`,
         number_interventions = INTERVENTIONS, interventions = `list interventions`) %>%
  mutate(year = year(incident_date))

shooting_2018 <- shooting_2018[1:150, ]

#jjor new petition

#format dates and factors
shooting_2017$dob <- as.Date(shooting_2017$dob, format = "%Y-%m_%d")
shooting_2017$incident_date <- shooting_2017$incident_date  %>% ymd_format()
shooting_2017$zipcode <- as.factor(shooting_2017$zipcode)
shooting_2017$arrests_prior <- as.numeric(shooting_2017$arrests_prior)

shooting_2018$dob <- as.Date(shooting_2018$dob, format = "%Y-%m_%d")
shooting_2018$incident_date <- shooting_2018$incident_date  %>% ymd_format()
shooting_2018$zipcode <- as.factor(shooting_2018$zipcode)
shooting_2018$calendar <- as.numeric(shooting_2018$calendar)
shooting_2018$number_petitions <- as.numeric(shooting_2018$number_petitions)
shooting_2018$total_probation_orders <- as.character(shooting_2018$total_probation_orders)

shootings_all <- shooting_2017 %>%
  bind_rows(shooting_2018)

shootings_all$home_address <- paste0(shootings_all$home_address, ", Chicago, IL")

#add autonumber to protect names. 
shootings_all <- shootings_all %>%
  mutate(id_number = 1:nrow(.), source = "Ally")

#dataset for geocoding
shootings_all_anon <- shootings_all %>%
  select(id_number, source, incident_date, race, gender,
         dob, type, home_address, initial_yasi_risk,
         police_district_arrest, police_district_residence)

write_csv(shootings_all_anon, "geocoding_shootings_all.csv")

write_rds(shootings_all_anon, "shootings_all.rds")
