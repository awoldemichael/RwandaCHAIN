
# Create 4x small multiples for each of the sub-IRs -----------------------
# 20 June 2016
# Laura Hughes, lhughes@usaid.gov

# ui code -----------------------------------------------------------------

indivResultUI = function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(leafletOutput(ns('resultsMap'))),
    
    fluidRow(imageOutput(ns('indivFooter2'), width = '100%'))
  )
}


# server code -------------------------------------------------------------

indivResult = function(input, output, session, df, selResult, 
                       ips, results, mechanisms){
  
  # filter the data to the District for indicated result -----------------------------------------
  
  filter_result = reactive({
    df %>% 
      # -- Filter out mechanisms based on user input --
      filter( 
             # mechanism %in% mechanisms(),
             subIR_ID %like% selResult) %>% 
             # IP %in% ips()) %>%
      # -- Group by District and count --
      group_by(Province, District) %>% 
      summarise(num = n(),
                ips = paste('&bull;', shortName, ': ', result, collapse = ' <br> '))
  })
  
  
  # GeoCenter tramp stamp ---------------------------------------------------
  output$indivFooter2 = renderImage({
    return(list(
      src = "img/footer_Rw.png",
      width = '100%',
      filetype = "image/png",
      alt = "Plots from USAID's GeoCenter"
    ))
  }, deleteFile = FALSE)
  
  # Leaflet map ---------------------------------------------------
  output$resultsMap = renderLeaflet({
    renderLeaflet({
      
      filteredDF = filter_result()
      
      print(filteredDF)
      
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
  })
  
  
  # -- fin --
}






