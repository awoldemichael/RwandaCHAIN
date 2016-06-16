library(leaflet)

setwd('~/Documents/USAID/Rwanda/data in/Rwanda_Admin2/')
rw = readOGR(dsn=".", layer="District_Boundary_2006")

rw_adm2@data = full_join(rw_adm2@data, filteredDF)

pal <- colorNumeric("YlGnBu", domain = NULL)


state_popup <- paste0("<strong>Province: </strong>", 
                      rw$Prov_Name, 
                      "<br><strong>District: </strong>", 
                      rw$District,
                      "<br><strong>number: </strong>", 
                      rw$num)


spacer = 0.01

minLon = rw@bbox['x', 'min'] * (1 - spacer)
minLat = rw@bbox['y', 'min'] * (1 - spacer)
maxLon = rw@bbox['x', 'max'] * (1 + spacer)
maxLat = rw@bbox['y', 'max'] * (1 + spacer)


leaflet(data = rw) %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>% 
  addPolygons(fillColor = ~pal(num), 
              fillOpacity = 0.8, 
              color = "#BDBDC3", 
              weight = 1,
              popup = state_popup)

rw@data = rw@data %>% filter(subIR_ID %like% '3')

leaflet(data = rw) %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>% 
  addPolygons(fillColor = ~pal(num), 
              fillOpacity = 0.8, 
              color = "#BDBDC3", 
              weight = 1,
              popup = state_popup)
