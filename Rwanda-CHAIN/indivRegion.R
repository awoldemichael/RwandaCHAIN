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
  
}






