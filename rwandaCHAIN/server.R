shinyServer(
  function(input, output, session) {
    
    # filter function ---------------------------------------------------------
    
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
    
    # individual tabs ---------------------------------------------------------
    callModule(indivRegion, 'west', df, 'West')
    
    # leaflet plot ------------------------------------------------------------
    
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
                           "<br><strong>mechanisms: </strong> <br>",
                           rw_adm2$ips)
      
      info_popup_circles <- paste0("<strong>District: </strong>", 
                           rw_centroids$District,
                           "<br><strong>mechanisms: </strong> <br>",
                           rw_centroids$ips)
      
      # -- leaflet map --
      leaflet(data = rw_adm2) %>%
        addProviderTiles("Esri.WorldGrayCanvas",
                         options = tileOptions(minZoom = 9, maxZoom  = 11)) %>%
        setMaxBounds(minLon, minLat, maxLon, maxLat) %>%
        addPolygons(fillColor = ~categPal(Prov_Name),
                    fillOpacity = 0.2,
                    color = grey90K,
                    weight = 1,
                    popup = info_popup) %>%
        addMarkers(data = rw_centroids, lng = ~Lon, lat = ~Lat,
                   label = ~as.character(num),
                 icon = makeIcon(
                   iconUrl = "img/footer_Rw.png",
                   iconWidth = 1, iconHeight = 1,
                   iconAnchorX = 0, iconAnchorY = 0),
                 labelOptions = lapply(1:nrow(rw_centroids),
                                       function(x) {
                                         labelOptions(opacity = 1, noHide = TRUE,
                                                      direction = 'auto',
                                                      offset = c(-10, -12))
                                       })
      )%>%
      addCircles(data = rw_centroids, lat = ~Lat, lng = ~Lon,
                 radius = ~num * circleScaling,
                 color = strokeColour, weight = 0.5,
                 popup = info_popup_circles,
                 fillColor = ~categPal(Province), fillOpacity = 0.25) 
    })
    
    # callModule(indivRegion, 'west', df, 'West')
    
    
    # Bar graph by province ---------------------------------------------------
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
        
        # -- Plot bar graph --
        ggvis(x = ~num, y = ~Province,
              fill = ~Province) %>% 
        layer_rects(x2 = 0, height = band(),
                   fillOpacity := 0.6) %>% 
        layer_text(text := ~num, 
                   fontSize := 24,
                   fontWeight := 300,
                   fill := grey90K,
                   dx := -15,
                   dy := 15,
                   align := 'right',
                   baseline:="top",
                   font := 'Segoe UI') %>% 
        scale_ordinal('fill', range = colourProv) %>% 
        # -- Axes --
        add_axis('x', ticks = 5, grid = FALSE,
                 title = '',
                 properties = axis_props(
                   axis = NA,
                   majorTicks = NA,
                   labels = NA)) %>%
        #            # grid = list(stroke = grey60K, strokeWidth = 0.75),
        #            # labels = list(
        #              # fill = grey70K,
        #              # fontSize = 16))) %>% 
        add_axis('y', grid = FALSE, title = '',
                 properties = axis_props(
                   labels = list(
                     fill = grey70K,
                     fontSize = 16),
                   majorTicks = NA,
                   axis = NA)) %>% 
        hide_legend('fill')
    }) %>% 
      bind_shiny('numByProv') 
    
    # footer image ------------------------------------------------------------
    
    output$footer = renderImage({
      return(list(
        src = "img/footer_Rw.png",
        width = '100%',
        filetype = "image/png",
        alt = "Plots from USAID's GeoCenter"
      ))
    }, deleteFile = FALSE)
  })









