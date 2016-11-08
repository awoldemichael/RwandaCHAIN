library(jsonlite)
library(tidyjson)


# Instructions on importing from json file directly -----------------------
# remove '\' from file
# replace '{"' with '{'
# replace '"}' with '}'

# Import data from Baboyma's dataset
sectors = jsonlite::fromJSON('~/GitHub/RwandaCHAIN/www/data/intervention-location_2016-11-08.json', flatten = T, simplifyMatrix = T, simplifyDataFrame = T)
sectors = sectors$data

interventions = jsonlite::fromJSON('~/GitHub/RwandaCHAIN/www/data/intervention-list.json', flatten = T, simplifyMatrix = T, simplifyDataFrame = T)
sectors = sectors$data


# merge together names ----------------------------------------------------
sectors = left_join(sectors, interventions)

# Filter out nutrition-related info ------------------------------------------


admin3_codebk = hh %>% 
  select(admin1, admin2, admin3, livelihood_zone) %>% 
  distinct()