library(leaflet)

setwd('~/Documents/USAID/Rwanda/data in/Rwanda_Admin2/')
rw = readOGR(dsn=".", layer="District_Boundary_2006")

rw@data = rw@data %>% mutate(x = dense_rank(Dist_ID))

pal <- colorQuantile("YlGn", NULL, n = 5)

state_popup <- paste0("<strong>Province: </strong>", 
                      rw$Prov_Name, 
                      "<br><strong>District: </strong>", 
                      rw$District)

leaflet(data = rw) %>%
  addProviderTiles("CartoDB.Positron") %>% 
  addPolygons(fillColor = ~pal(-x), 
              fillOpacity = 0.8, 
              color = "#BDBDC3", 
              weight = 1,
              popup = state_popup)

