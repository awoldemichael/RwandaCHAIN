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
    callModule(indivRegion, 'east', df, 'Eastern Province', 
               reactive(input$filterIP), reactive(input$filterResult), 
               reactive(input$filterMech))
    
    callModule(indivRegion, 'kigali', df, 'Kigali City', 
               reactive(input$filterIP), reactive(input$filterResult), 
               reactive(input$filterMech))
    
    callModule(indivRegion, 'north', df, 'Northern Province', 
               reactive(input$filterIP), reactive(input$filterResult), 
               reactive(input$filterMech))
    
    callModule(indivRegion, 'south', df, 'Southern Province', 
               reactive(input$filterIP), reactive(input$filterResult), 
               reactive(input$filterMech))
    
    callModule(indivRegion, 'west', df, 'Western Province', 
               reactive(input$filterIP), reactive(input$filterResult), 
               reactive(input$filterMech))
    
    
    # individual results ------------------------------------------------------
    
    callModule(indivResult, 'subIR1', df, '1', 
               reactive(input$filterIP), reactive(input$filterResult), 
               reactive(input$filterMech))
    
    callModule(indivResult, 'subIR2', df, '2', 
               reactive(input$filterIP), reactive(input$filterResult), 
               reactive(input$filterMech))
    
    callModule(indivResult, 'subIR3', df, '3', 
               reactive(input$filterIP), reactive(input$filterResult), 
               reactive(input$filterMech))
    
    callModule(indivResult, 'subIR4', df, '4', 
               reactive(input$filterIP), reactive(input$filterResult), 
               reactive(input$filterMech))
    # GeoCenter tramp stamp ---------------------------------------------------
    output$indivFooter2 = renderImage({
      return(list(
        src = "img/footer_Rw.png",
        width = '100%',
        filetype = "image/png",
        alt = "Plots from USAID's GeoCenter"
      ))
    }, deleteFile = FALSE)
    
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
                    fillOpacity := 0.6)  %>% 
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
                   labels = list(fontSize = 0),
                   majorTicks = list(strokeWidth = 0),
                   axis = list(strokeWidth = 0))) %>%
        add_axis('y', grid = FALSE, title = '',
                 properties = axis_props(
                   labels = list(
                     fill = grey70K,
                     fontSize = 16),
                   majorTicks = list(strokeWidth = 0),
                   axis = list(strokeWidth = 0))) %>%
        hide_legend('fill')
    }) %>% 
      bind_shiny('numByProv') 
    
    # overlap matrix ------------------------------------------------------------
    output$overlap = renderPlot({
      filterDF  = reactive({
        df %>% 
          # -- Filter out mechanisms based on user input --
          filter(mechanism %in% input$filterMech, 
                 result %in% input$filterResult,
                 IP %in% input$filterIP, 
                 Province %in% input$selProv) %>%
          
          # -- Calculate binary if work in district --
          group_by(Province, District, shortName) %>% 
          summarise(num = n()) %>% 
          mutate(isActive = num > 0) %>%
          ungroup() %>% 
          select(District, shortName, isActive) %>%
          spread(District, isActive)
      })
      
      filteredDF = filterDF()
      
      # Convert to a matrix
      df2Dot = as.matrix(filteredDF %>% ungroup() %>% select(-shortName))
      
      # replace all NAs with 0
      df2Dot[is.na(df2Dot)] = 0
      
      # Create matrix transpose
      dfTranspose = t(df2Dot) 
      
      # Calculate dot product == sum of where the two values are both 1. 
      # Thanks @nada
      overlapMatrix = df2Dot %*% dfTranspose
      
      # Remove half the matrix since it's duplicative
      overlapMatrix[lower.tri(overlapMatrix, diag = TRUE)] = NA
      
      # Rename to be the IP names and reshape long
      colnames(overlapMatrix) = filteredDF$shortName
      
      overlapMatrix = data.frame(ip1 = filteredDF$shortName, overlapMatrix)
      
      overlapMatrix = gather(overlapMatrix, ip2, numDist, -ip1) %>% 
        mutate(ip2 = str_replace(ip2, '\\.', ' '), #Remove . introduced by rownames
               colourText = ifelse(is.na(numDist), NA,
                                   ifelse(numDist > median(numDist, na.rm = TRUE), grey15K, grey90K))
        ) #
      
      # Refactorize levels
      overlapMatrix$ip2 = factor(overlapMatrix$ip2, 
                                 levels = rev(overlapMatrix$ip2))
      
      ggplot(overlapMatrix, aes(x = ip1, y = ip2, 
                                fill = numDist, size = numDist)) +
        geom_point(shape = 21) +
        geom_text(aes(label = numDist, colour = colourText),
                  size  = 4) +
        # geom_text(aes(label = ip2), colour = grey70K,
        # hjust = 1, nudge_x = 0.1,
        # size  = 5, data = overlapMatrix) +
        scale_size_continuous(range = c(4, 14),
                              limits = c(1, max(overlapMatrix$numDist))) +
        scale_colour_identity() +
        scale_fill_gradientn(colours = brewer.pal(9,'YlGn')[2:9]) +
        theme_void() +
        theme(text = element_text(colour = grey70K, size = 16),
              line = element_line(colour = grey70K, size = 0.15, linetype = 1, lineend = 'butt'),
              axis.line = element_line(),
              axis.ticks = element_blank(),
              panel.grid.major = element_line(colour = grey70K), 
              panel.grid.minor = element_line(colour = grey70K), 
              axis.text.x = element_text(),
              axis.text.y = element_text(),
              legend.position = 'none')
    })
    
    
    # footer image ------------------------------------------------------------
    
    output$footer = renderImage({
      return(list(
        src = "img/footer_Rw.png",
        width = '100%',
        filetype = "image/png",
        alt = "Plots from USAID's GeoCenter"
      ))
    }, deleteFile = FALSE)
    
    output$footer2 = renderImage({
      return(list(
        src = "img/footer_Rw.png",
        width = '100%',
        filetype = "image/png",
        alt = "Plots from USAID's GeoCenter"
      ))
    }, deleteFile = FALSE)
    
    # -- fin --   
  })