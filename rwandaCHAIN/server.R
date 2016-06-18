shinyServer(
  function(input, output, session) {
    
    filterDF = reactive({
      df %>% 
        filter(mechanism == input$filterIM,
               result == input$filterIR) %>% 
        group_by(District, IP) %>% 
        summarise(num = n())
    })
    
    
    
    output$main = renderLeaflet({
      
      filteredDF = filterDF()
      
      rw_adm2@data = full_join(rw_adm2@data, filteredDF)
      
      # -- Pull out the centroids --
      rw_centroids = data.frame(coordinates(rw_adm2)) %>% 
        rename(Lon = X1, Lat = X2)
      
      rw_centroids = cbind(rw_centroids,
                           District = rw_adm2@data$District)
      
      rw_centroids = full_join(rw_centroids, filteredDF)
      
      
      # -- Info popup box -- 
      info_popup <- paste0("<strong>Province: </strong>", 
                           rw_adm2$Prov_Name, 
                           "<br><strong>District: </strong>", 
                           rw_adm2$District,
                           "<br><strong>number: </strong>", 
                           rw_adm2$num)
      
      leaflet(data = rw_adm2) %>%
        addProviderTiles("Esri.WorldGrayCanvas", 
                         options = tileOptions(minZoom = 8, maxZoom  = 11)) %>% 
        setMaxBounds(minLon, minLat, maxLon, maxLat) %>% 
        addPolygons(fillColor = baseColour, 
                    fillOpacity = 0.8, 
                    color = "#BDBDC3", 
                    weight = 1,
                    popup = info_popup) %>% 
        addCircles(data = rw_centroids, lat = ~Lat, lng = ~Lon,
                   radius = ~num*200, 
                   color = strokeColour, weight = 0.5,
                   fillColor = ~pal(num), fillOpacity = 1,
                   label = ~District,
                   labelOptions = lapply(1:nrow(rw_centroids), function(x) {
                     labelOptions(opacity=0.9, noHide = TRUE)
                   })
        )
      
    })
    
    # callModule(indivRegion, 'west', df, 'West')
    
    
    leaflet(rw_centroids) %>% addTiles() %>%
      addCircleMarkers(lng = ~Lon, lat = ~Lat,
                       label = ~District,
                       labelOptions = lapply(1:nrow(rw_centroids), function(x) {
                         labelOptions(opacity = 1, noHide = T)
                       })
      )
    
  })