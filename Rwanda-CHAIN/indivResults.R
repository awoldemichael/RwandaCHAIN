
# Create 4x small multiples for each of the sub-IRs -----------------------
# 20 June 2016
# Laura Hughes, lhughes@usaid.gov

# ui code -----------------------------------------------------------------

indivResultUI = function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(htmlOutput(ns('title'))),
    fluidRow(leafletOutput(ns('resultsMap')))
    
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
        mechanism %in% mechanisms(),
        subIR_ID %like% selResult,
        IP %in% ips()) %>%
      # -- Group by District and count --
      group_by(Province, District) %>% 
      summarise(num = n(),
                ips = paste('&bull;', shortName, ': ', result, collapse = ' <br> '))
  })
  
  
  
  # Leaflet map ---------------------------------------------------
  output$resultsMap = renderLeaflet({
    
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
                       options = tileOptions(minZoom = 8, maxZoom  = 11)) %>%
      setMaxBounds(minLon, minLat, maxLon, maxLat) %>% 
      addPolygons(fillColor = ~contPal(num),
                  fillOpacity = 0.6,
                  color = grey90K,
                  weight = 1,
                  popup = info_popup)
  })
  
  output$title = renderPrint({
    h2(paste0('sub IR ', selResult))
  })
  # -- fin --
}






