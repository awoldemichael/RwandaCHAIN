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
      
      pal <- colorNumeric("YlGnBu", domain = NULL)
      
      info_popup <- paste0("<strong>Province: </strong>", 
                           rw_adm2$Prov_Name, 
                           "<br><strong>District: </strong>", 
                           rw_adm2$District,
                           "<br><strong>number: </strong>", 
                           rw_adm2$num)
      
      leaflet(data = rw_adm2) %>%
        addProviderTiles("Esri.WorldGrayCanvas", 
                         options = tileOptions(minZoom = 8, maxZoom  = 11)) %>% 
        addPolygons(fillColor = ~pal(num), 
                    fillOpacity = 0.8, 
                    color = "#BDBDC3", 
                    weight = 1,
                    popup = info_popup)
      
    })
    
    # callModule(indivRegion, 'west', df, 'West')
    
  })