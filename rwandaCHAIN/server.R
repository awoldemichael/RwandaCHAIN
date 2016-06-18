shinyServer(
  function(input, output, session) {
    
    filter_byDist = reactive({
      df %>% 
        # -- Filter out mechanisms based on user input --
        filter(mechanism %in% input$filterMech, 
               result %in% input$filterResult,
               IP %in% input$filterIP) %>%
        # -- Remove the results data and compress --
        select(Province, District, shortName, IP, mechanism) %>% 
        distinct() %>% 
        # -- Group by District and count --
        group_by(Province, District) %>% 
        summarise(num = n(),
                  ips = paste('&bull;', mechanism, collapse = ' <br> '))
    })
    
    
    
    output$main = renderLeaflet({
      
      filteredDF = filter_byDist()
      
      
      rw_adm2@data = full_join(rw_adm2@data, filteredDF)
      
      # -- Pull out the centroids --
      rw_centroids = data.frame(coordinates(rw_adm2)) %>% 
        rename(Lon = X1, Lat = X2)
      
      rw_centroids = cbind(rw_centroids,
                           District = rw_adm2@data$District)
      
      rw_centroids = left_join(filteredDF, rw_centroids)
      
      
      # -- Info popup box -- 
      info_popup <- paste0("<strong>District: </strong>", 
                           rw_adm2$District,
                           "<br><strong>number: </strong>", 
                           rw_adm2$num,
                           "<br><strong>mechanisms: </strong> <br>",
                           rw_adm2$ips)
      
      leaflet(data = rw_adm2) %>%
        addProviderTiles("Esri.WorldGrayCanvas",
                         options = tileOptions(minZoom = 9, maxZoom  = 11)) %>%
        setMaxBounds(minLon, minLat, maxLon, maxLat) %>%
        addPolygons(fillColor = ~categPal(Prov_Name),
                    fillOpacity = 0.2,
                    color = grey90K,
                    weight = 1,
                    popup = info_popup) %>%
        # addMarkers(data = rw_centroids, lng = ~Lon, lat = ~Lat,
        #            label = ~District,
        #            icon = makeIcon(
        #              iconUrl = "http://leafletjs.com/docs/images/leaf-green.png",
        #              iconWidth = 01, iconHeight = 01,
        #              iconAnchorX = 0, iconAnchorY = 0),
        #            labelOptions = lapply(1:nrow(rw_centroids), 
        #                                  function(x) {
        #                                    labelOptions(opacity = 1, noHide = TRUE,
        #                                                 direction = 'auto',
        #                                                 offset = c(0, 0))
      #                                  }) 
      # )%>%
      addCircles(data = rw_centroids, lat = ~Lat, lng = ~Lon,
                 radius = ~num * circleScaling,
                 color = strokeColour, weight = 0.5,
                 popup = info_popup,
                 fillColor = ~categPal(Province), fillOpacity = 0.25)
    })
    
    # callModule(indivRegion, 'west', df, 'West')
    
    
    # Bar graph by province ---------------------------------------------------
    # mtcars %>% ggvis(x = ~cyl, y = ~mpg) %>% ggvis::layer_bars() %>% bind_shiny('numByProv') 
    reactive({
      df %>% 
        # -- Filter out mechanisms based on user input --
        filter(mechanism %in% input$filterMech, 
               result %in% input$filterResult,
               IP %in% input$filterIP) %>%
        # -- Remove the results data and compress --
        select(Province, shortName, IP, mechanism) %>% 
        distinct() %>% 
        # -- Group by Province and count --
        group_by(Province) %>% 
        summarise(num = n()) %>% 
        ggvis(x = ~num, y = ~Province) %>% 
        layer_rects(x2 = 0, height = band()) }) %>% 
      bind_shiny('numByProv') 
    
  })


