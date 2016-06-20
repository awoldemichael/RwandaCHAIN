# ui code -----------------------------------------------------------------

indivRegionUI = function(id){
  ns <- NS(id)
  
  tagList(
    # -- Render the reference map --
    fluidRow(column(5, imageOutput(ns('refMap'))),
             
             column(7, 
                    # -- Controls --
                    fluidRow(column(6, selectizeInput(ns('mech1'), label = '#1', choices = mechanisms)),
                             column(6, selectizeInput(ns('mech2'), label = '#2', choices = mechanisms))),
                    fluidRow(plotOutput(ns('indivSubIR'))))),
    
    fluidRow(column(6,plotOutput(ns('map1'))),
             column(6,plotOutput(ns('map2')))
    ),
    
    fluidRow(imageOutput(ns('indivFooter'), width = '100%'))
  )
}




# server code -------------------------------------------------------------

indivRegion = function(input, output, session, df, selRegion, 
                       ips, results, mechanisms){
  
  # filter the data to the Province -----------------------------------------
  
  filter_byResult = reactive({
    df %>% 
      # -- Filter out mechanisms based on user input --
      filter(Province == selRegion, 
             mechanism %in% mechanisms(),
             result %in% results(),
             IP %in% ips()) %>%
      # -- Group by District and count --
      group_by(Province, District, shortName) %>% 
      summarise(num = n(),
                ips = paste('&bull;', mechanism, collapse = ' <br> '))
  })
  
  
  # GeoCenter tramp stamp ---------------------------------------------------
  output$indivFooter = renderImage({
    return(list(
      src = "img/footer_Rw.png",
      width = '100%',
      filetype = "image/png",
      alt = "Plots from USAID's GeoCenter"
    ))
  }, deleteFile = FALSE)
  
  
  # individual map ----------------------------------------------------------
  
  output$refMap = renderImage({
    return(list(
      src = paste0("img/rwanda_", selRegion, '.png'),
      width = '100%',
      filetype = "image/png",
      alt = "Plots by USAID's GeoCenter"
    ))
  }, deleteFile = FALSE)
  
  
  # filter the data for the dot Matrix -----------------------------------------
  
  filter_dotMatrix = reactive({
    df %>% 
      # -- Filter out mechanisms based on user input --
      filter(Province == selRegion, 
             mechanism %in% c(input$mech2, input$mech1),
             result %in% results(),
             IP %in% ips()) %>%
      # -- Group by subIR and count --
      group_by(mechanism, subIR_ID, result) %>% 
      summarise(num = n()) %>% 
      # -- spread into a wide dataset --
      spread(mechanism, num) 
  })
  
  
  # individual subIR matrix -------------------------------------------------
  output$indivSubIR = renderPlot({
    filteredDF = filter_dotMatrix()
    
    print(filteredDF %>% select(-result))
    
    ggplot(filteredDF, aes(y = subIR_ID)) +
      geom_point(aes_(x = 'x'), size = 10, colour = redAccent) + 
      # geom_point(aes_(x = input$mech2), size = 10, colour = blueAccent) + 
      theme_bw()
  })
  
  
  output$indivRegion = renderPlot({
    filteredDF = filter_byResult() 
    
    f = filteredDF %>%
      ungroup() %>%
      group_by(District, shortName) %>%
      summarise(num = sum(num)) %>% 
      arrange(desc(num))
    
    f$shortName = factor(f$shortName,
                         levels = f$shortName)
    
    f$District = factor(f$District,
                        levels = f$District) 
    
    ggplot(f, aes(y = District,
                  x = shortName,
                  fill = num)) +
      geom_tile(colour = 'white', size = 0.25) +
      theme_xylab() +
      scale_fill_gradientn(colours = brewer.pal(9, 'Blues')[4:9])
    
    # filteredDF = df %>%
    #   # -- Filter out mechanisms based on user input --
    #   filter(Province == 'Western Province') %>%     # -- Group by District and count --
    #   group_by(Province, District, shortName, subIR_ID) %>%
    #   summarise(num = n(),
    #             ips = paste('&bull;', mechanism, collapse = ' <br> ')) %>% 
    #   ungroup() %>% 
    #   group_by(District, shortName) 
    # 
    # f =   df %>%
    #   # -- Filter out mechanisms based on user input --
    #   filter(Province == 'Western Province') %>%
    #   # -- Group by District and count --
    #   group_by(Province, District, shortName) %>%
    #   summarise(num = n(),
    #             subIR_ID = 'total', ips='')
    # 
    # filteredDF = rbind(filteredDF, f)
    
    
    # ggplot(f, aes(x = 1,
    #                        y = shortName,
    #                        fill = num)) +
    #   geom_tile(colour = 'white', size = 0.25) +
    #   facet_wrap(~District) +
    #   theme_xylab() +
    #   scale_fill_gradientn(colours = brewer.pal(9, 'Blues')[4:9])
    
  })
  
  
  # filter the data for map1 -----------------------------------------
  
  filter_map1 = reactive({
    
    map1 = df %>% 
      # -- Filter out mechanisms based on user input --
      filter(Province == selRegion, 
             mechanism %in% c(input$mech1),
             result %in% results(),
             IP %in% ips()) %>%
      # -- Group by District and count --
      group_by(Province, District) %>% 
      summarise(num = n())
    
    left_join(map1, rw.df)
  })
  
  
  output$map1 = renderPlot({
    filteredMap1 = filter_map1()
    
    ggplot(rw.df %>% filter(Prov_Name == selRegion), aes(x = long, y = lat, group = group)) +
      # -- Base map --
      geom_polygon(fill = grey15K) +
      
      # -- Current
      geom_polygon(fill = redAccent, 
                   data = filteredMap1,
                   alpha = 0.75) +
      geom_path(colour = grey90K, size = 0.1) +
      coord_equal() +
      ggtitle(input$mech1) +
      theme_void()
  })
  
  # filter the data for map2 -----------------------------------------
  
  filter_map2 = reactive({
    
    map2 = df %>% 
      # -- Filter out mechanisms based on user input --
      filter(Province == selRegion, 
             mechanism %in% c(input$mech2),
             result %in% results(),
             IP %in% ips()) %>%
      # -- Group by District and count --
      group_by(Province, District) %>% 
      summarise(num = n())
    
    left_join(map2, rw.df)
  })
  
  
  output$map2 = renderPlot({
    filteredMap2 = filter_map2()
    
    ggplot(rw.df %>% filter(Prov_Name == selRegion), aes(x = long, y = lat, group = group)) +
      # -- Base map --
      geom_polygon(fill = grey15K) +
      
      # -- Current
      geom_polygon(fill = blueAccent, 
                   data = filteredMap2,
                   alpha = 0.75) +
      geom_path(colour = grey90K, size = 0.1) +
      coord_equal() +
      ggtitle(input$mech2) +
      theme_void()
  })
}






