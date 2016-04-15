# Load required packages
library(foreign)
library(hmisc)
library(dplyr)


setwd("~/GitHub/RwandaCHAIN/GIS")

# Read in DBF from shapfile
d = read.dbf("Rwanda_admin_2014_WGS84.dbf")

ADM2 = d %>% group_by(ADM0, ADM1, ADM2) %>% 
  summarise(ojb = mean(OBJECTID)) %>%
  select(-(ojb)) %>%
  arrange(ADM0, ADM1, ADM2)


write.csv(ADM2, "Rwanda_Admin_info.csv")
