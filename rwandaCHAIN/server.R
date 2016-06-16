shinyServer(
  function(input, output, session) {
    
    filterDF = reactive({
      df %>% 
        filter(mechanism == input$filterIM,
               result == input$filterIR) %>% 
        group_by(District, IP) %>% 
        summarise(num = n())
    })
    
    
    output$smMult = renderPlot({
      
      filteredDF = filterDF()
      
      rw.df2 = full_join(rw.df, filteredDF, by = c("District"))
      
      ggplot(rw.df2) + 
        aes(x = long, y = lat) +
        geom_polygon(aes(group = group, fill = Prov_Name)) +
        geom_path(aes(group = group),
                  colour = 'white',
                  size = 0.1) +
        coord_equal() +
        theme_blank() +
        scale_fill_brewer(palette = 'Set1') +
        facet_wrap(~IP)
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
        addProviderTiles("Esri.WorldGrayCanvas") %>% 
        addPolygons(fillColor = ~pal(num), 
                    fillOpacity = 0.8, 
                    color = "#BDBDC3", 
                    weight = 1,
                    popup = info_popup)
      
    })
    
    # callModule(indivRegion, 'west', df, 'West')
    
  })