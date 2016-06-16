# Code to clean up Rwanda CHAIN IP data -----------------------------------
# Laura Hughes, April 2016, lhughes@usaid.gov
# Note: this code isn't impeccably documented, so please send questions 
# if needed and I can clean it up. It's documented to make sense to me 
# (hopefully) but probably makes no sense to others.


# Installing packages ------------------------------------------------
# In Mac OS X, need to install GDAL first.
# In terminal, install macports: https://www.macports.org/install.php
# Then 'sudo port install gdal'
# Go back to R and install rgdal
# install.packages("rgdal",  type="source")

# AND then rgeos.
# http://tlocoh.r-forge.r-project.org/mac_rgeos_rgdal.html
# Reinstall R, since El Capitan has problems w/ saving to usr/lib 
# Install geos: http://www.kyngchaos.com/ 
# Then install in R: install.packages('rgeos)

library(llamar)
library(splitstackshape) 
library(rgdal)
library(maptools)
library(rgeos)
library(raster)
library(rasterVis)
llamar::loadPkgs()


# Import and clean “raw” data -----------------------------------------------------

# Read in .shp files ------------------------------------------------------

# Admin 2
setwd('~/Documents/USAID/Rwanda/data in/Rwanda_Admin2/')
rw = readOGR(dsn=".", layer="District_Boundary_2006")
rw@data$id = rownames(rw@data)
rw.points = fortify(rw, region="id")
rw.df = plyr::join(rw.points, rw@data, by="id")

rwAdm2 = rw@data

# Admin 1
setwd('~/Documents/USAID/Rwanda/data in/Rwanda_Admin1/')
rw_adm1 = readOGR(dsn=".", layer="Province_Boundary_2006")
rw_adm1@data$id = rownames(rw_adm1@data)
adm1.points = fortify(rw_adm1, region="id")
adm1.df = plyr::join(adm1.points, rw_adm1@data, by="id")


# Admin 0
setwd('~/Documents/USAID/Rwanda/data in/Rwanda basemaps/')
rw_adm0 = readOGR(dsn=".", layer="RWA_Adm0")
rw_adm0@data$id = rownames(rw_adm0@data)
adm0.points = fortify(rw_adm0, region="id")
adm0.df = plyr::join(adm0.points, rw_adm0@data, by="id")

ggplot(adm0.df) + 
  aes(x = long, y = lat) +
  geom_path(aes(group = group),
            color= grey70K, size = 0.25) +
  scale_x_continuous(limits = range(adm0.df$long) + c(0.001, -0.001)) +
  scale_y_continuous(limits = range(adm0.df$lat) + c(0.001, -0.001)) +
  theme_blank()

# Lakes
setwd('~/Documents/USAID/Rwanda/data in/Rwanda basemaps/')
rw_lakes = readOGR(dsn=".", layer="RWA_Lakes")
rw_lakes@data$id = rownames(rw_lakes@data)
lakes.points = fortify(rw_lakes, region="id")
lakes.df = plyr::join(lakes.points, rw_lakes@data, by="id")

# Terrain
rw_terrain = readGDAL('~/Documents/USAID/Rwanda/data in/Rwanda basemaps/RWA_Terrain.tif')

rw_terrain = raster('~/Documents/USAID/Rwanda/data in/Rwanda basemaps/RWA_Terrain.tif')

map.df <- data.frame(rasterToPoints(rw_terrain))



# Pull out the centroids of the coords and the names of the districts
rw.centroids = data.frame(coordinates(rw)) %>% 
  rename(long = X1, lat = X2)

rw.centroids = cbind(rw.centroids,
                     district = rw@data$District)

adm1.centroids = data.frame(coordinates(rw_adm1)) %>% 
  rename(long = X1, lat = X2)

adm1.centroids = cbind(adm1.centroids,
                       province = rw_adm1@data$Prov_Name)



# Raw shapefile in R
rwShp <- readShapePoly('~/Documents/USAID/Rwanda/data in/Rwanda_Admin3/Rwanda_Admin_Three.shp')

rwAdm3 = rwShp@data %>% 
  mutate(Province = ifelse(Province == 'Iburengerazuba',
                           'Western Province', as.character(Province))) %>%  # Iburengerazuba == West
  group_by(District) %>% 
  mutate(isDistrict = dense_rank(Sector), # Create a flag if the data are district-level
         isDistrict = ifelse(isDistrict == 1, 1, 0))



# Pull out all the Adm2 names for each Adm1
findAdm2 = function(adm1Name){
  districts = rwAdm3 %>% 
    filter(isDistrict == 1,
           Province %like% adm1Name) %>% 
    select(District)
  
  districts = unique(as.character(districts$District)) # Eliminate duplicates; converts from a factor to a character
  
  districts = paste0(districts, collapse = ', ') # Convert to a string
}

northDistricts = findAdm2('North')
southDistricts = findAdm2('South')
eastDistricts = findAdm2('East')
westDistricts = findAdm2('West')
kigaliDistricts = findAdm2('Kigali')
allDistricts = paste(northDistricts, southDistricts, kigaliDistricts,
                     eastDistricts, westDistricts, sep = ', ')


# Project locations -------------------------------------------------------
df = read_excel('~/Documents/USAID/Rwanda/CHAIN/datain/Locations of CHAIN IMs in Rwanda (2016-03-22).xlsm')

# Cleanup #1: rename columns
# Fix any values that are "all" region/country
df2 = df %>% 
  select(-`To include by Geo Center?`) %>% # Drop unneeded columns
  rename(project = Project,
         mechanism = `Implementing Mechanism`,
         IP = `Implementing Partner`,
         manager = `AOR/COR or Activity Manager`,
         nationwide = `Nationwide?\r\n(If yes, skip the remaining columns)`) %>% # rename so easier to deal with
  mutate(nationwide = ifelse(nationwide %in% c('Yes', 'yes', 'Y', 'y'), # If all of the province or country are selected, convert to a list of the Adm2 names.
                             allDistricts, NA),
         `Kigali Province` = ifelse(`Kigali Province` %like% 'All', 
                                    kigaliDistricts, `Kigali Province`),
         `Northern Province` = ifelse(`Northern Province` %like% 'All', 
                                      northDistricts, `Northern Province`),
         `Southern Province ` = ifelse(`Southern Province ` %like% 'All', 
                                       southDistricts, `Southern Province `),
         `Eastern Province` = ifelse(`Eastern Province` %like% 'All', 
                                     eastDistricts, `Eastern Province`),
         `Western Province` = ifelse(`Western Province` %like% 'All', 
                                     westDistricts, `Western Province`))

# Split Nationwide into each individual district
df2 = cSplit(df2, 'nationwide', ',')


# Split Kigali into individual districts
df2 = cSplit(df2, 'Kigali Province', ',')

# Split Northern into individual districts
df2 = cSplit(df2, 'Northern Province', ',')

# Split Western into individual districts
df2 = cSplit(df2, 'Western Province', ',')

# Split Southern into individual districts
df2 = cSplit(df2, 'Southern Province ', ',')

# Split Eastern into individual districts
df2 = cSplit(df2, 'Eastern Province', ',')

# Convert to a tidy data frame
df2 = df2 %>% 
  gather(regCol, District, -project, -mechanism, -IP, -manager, -shortName) %>% # convert from wide to long df
  select(-regCol) %>% # Remove column generated by gathering
  filter(!is.na(District), District != 'N/A') # remove NAs


# Add in the results data -----------------------------------------------------------------

results = read_excel('~/Documents/USAID/Rwanda/CHAIN/datain/RF Map to Partners_LH.xlsx')
codebook = read_excel('~/Documents/USAID/Rwanda/CHAIN/datain/Partner Lookup Table.xlsx')

# Split the column based on the comma
results = cSplit(results, 'Partners', ',') %>% 
  gather(partnerNum, partner, -output, -result, -output_ID, -subIR_ID, -INWA) %>% # Convert from wide to long dataset
  select(-partnerNum) %>%  # Remove artifact of split/gather
  filter(!is.na(partner),
         !partner %in% c('Education', 'PIO', 'RIPDD', 'RISWP')) %>% # Remove blank lines and things not yet procured
  filter(!partner %in% c('GAIN', 'EDC')) %>% # No location data
  select(-INWA)
  # mutate(INWA = ifelse(INWA %like% 'No INWA', 0, 1)) # Convert to binary


# Translate the results into the full file
results = left_join(results, codebook, by = c("partner" = "Code"))

# Merge df w/ Adm names ---------------------------------------------------
df_full = full_join(df2, rwAdm3, by = c("District" = "District")) 

df_full = full_join(df_full, results, by = c("IP" = "Implementing Partner",
                                             "mechanism" = "Implementing Mechanism")) %>% 
  ungroup() %>% 
  group_by(Province, District, Sector, mechanism) %>% 
  mutate(isSector = dense_rank(result),
         isSector = ifelse(is.na(isSector), 1,
                           ifelse(isSector == 1, 1, 0)))

df_adm2 = full_join(df2, rwAdm2, by = c("District" = "District")) %>% 
  rename(Province = Prov_Name) %>% 
  mutate(Province = str_replace_all(Province, ' Province', ''))

df_adm2 = full_join(df_adm2, results, by = c("IP" = "Implementing Partner",
                                             "mechanism" = "Implementing Mechanism"))


# Save the results
write.csv(df_full, '~/Documents/USAID/Rwanda/CHAIN/dataout/RW_projects_2016-06-14.csv')
write.csv(df_adm2, '~/Documents/USAID/Rwanda/CHAIN/dataout/RW_projects_adm2_2016-06-14.csv')

