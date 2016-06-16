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


spacer = 0.5

minLon = rw@bbox['x', 'min']
minLat = rw@bbox['y', 'min']
maxLon = rw@bbox['x', 'max']
maxLat = rw@bbox['y', 'max']


leaflet(data = rw) %>%
  addProviderTiles("Esri.WorldGrayCanvas", 
                   options = tileOptions(minZoom = 8, maxZoom  = 11)) %>% 
  addPolygons(fillColor = ~pal(Dist_ID), 
              fillOpacity = 0.8, 
              color = "#BDBDC3", 
              weight = 1,
              popup = state_popup)
  
  # setView(lng = (minLon + maxLon)/2, lat = (minLat + maxLat)/2, 
          # zoom = 8, options = list('maxZoom = 9'))
  setMaxBounds(minLon, minLat, maxLon, maxLat)

rw@data = rw@data %>% filter(subIR_ID %like% '3')

leaflet(data = rw) %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>% 
  addPolygons(fillColor = ~pal(num), 
              fillOpacity = 0.8, 
              color = "#BDBDC3", 
              weight = 1,
              popup = state_popup)
