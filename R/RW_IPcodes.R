# Libraries
library(dplyr)
library(stringr)
library(readxl)
# Load in data
rw = read.csv('~/Documents/USAID/Rwanda/CHAIN/dataout/RW_projects_adm2_2016-06-14.csv')

ip_codes = read_excel('~/Documents/USAID/Rwanda/CHAIN/Rwanda-Programs/docs/companies.xlsx')

# Select and rectify codes
rw2 = rw %>% 
  select(mechanism, shortName, IP, 
         ProvID = Prov_ID, ProvinceName = Province, 
         DistID = Dist_ID, DistName = District) %>% 
  mutate(shortName = case_when(rw$shortName == 'INWA' ~ 'CRS',
                               rw$shortName == 'HarvestPlus' ~ 'Hplus',
                               rw$shortName == 'OFSP' ~ 'CIP',
                               rw$shortName == 'HICD' ~ 'DAI',
                               rw$shortName == 'ISVP' ~ 'GC',
                               rw$shortName == 'RDCP II' ~ 'LOL',
                               rw$shortName == 'RSMP' ~ 'SFH',
                               TRUE ~ as.character(rw$shortName)
  )) %>% 
  mutate(pcode = ifelse(shortName %in% ip_codes$code, shortName, NA))


# Checking merge correctly
rw2 %>% filter(is.na(pcode)) %>% group_by(IP, mechanism, shortName) %>% summarise(n())

left_join(ip_codes, rw2, by = c("code" = "pcode")) %>% group_by(code) %>% summarise(n = n()) %>% arrange(desc(n))


# get rid of junk, save ---------------------------------------------------

rw2 = rw2 %>% 
  filter(!is.na(pcode)) %>% 
    select(pcode, ProvID, ProvinceName, DistID, DistName)

# Add in "All Districts" option for HICD
rw2 = bind_rows(rw2, data.frame(pcode = 'DAI', ProvID = 0, ProvinceName = 'All Districts', DistID = 0, DistName = 'All Districts'))

write.csv(rw2, '~/Documents/USAID/Rwanda/CHAIN/Rwanda-Programs/data/ip_by_district.csv')
