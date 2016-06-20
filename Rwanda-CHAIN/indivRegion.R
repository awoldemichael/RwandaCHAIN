# ui code -----------------------------------------------------------------

indivRegionUI = function(id){
  ns <- NS(id)
  
  tagList(
    # -- Controls --
    fluidRow(column(4, " "),
             column(3, selectizeInput(ns('mech1'), label = '#1', choices = mechanisms)),
             column(3, selectizeInput(ns('mech2'), label = '#2', choices = mechanisms))),
    
    # -- Render the reference map --
    
    fluidRow(column(4, " "),
             column(8, h3('overlap in intended result'))),
    fluidRow(
      column(4, imageOutput(ns('refMap'), width = widthDot)),
      column(3, plotOutput(ns('indivSubIR'), width = widthDot))),
    
    # -- Dot plots and maps of the two mechanisms to be compared --
    fluidRow(column(4, " "),
             column(8, h3('District overlap'))),
    fluidRow(column(1, " "),
             column(3, plotOutput(ns('map1'))),
             column(3, plotOutput(ns('indivDist'), width = widthDot)),
             column(1, " "),
             column(3, plotOutput(ns('map2')))
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
    results1 = df %>% 
      # -- Filter out mechanisms based on user input --
      filter(result %in% results(), # remove results if unchecked by user
             Province == selRegion, # limit to the selected region
             mechanism %in% c(input$mech1)) %>% # select the first mechanism from the dropdown menu
      
      # -- Group by subIR and count --
      group_by(mechanism, subIR_ID, result) %>% 
      summarise(num = n()) %>% 
      mutate(mech1_result = num > 0) %>% # convert to binary
      ungroup() %>% 
      select(subIR_ID, mech1_result)
    
    results2 = df %>% 
      # -- Filter out mechanisms based on user input --
      filter(result %in% results(), # remove results if unchecked by user
             Province == selRegion, # limit to the selected region
             mechanism %in% c(input$mech2)) %>% # select the second mechanism from the dropdown menu
      
      # -- Group by subIR and count --
      group_by(mechanism, subIR_ID, result) %>% 
      summarise(num = n()) %>% 
      mutate(mech2_result = num > 0) %>% # convert to binary
      ungroup() %>% 
      select(subIR_ID, mech2_result, result)
    
    
    full_join(results1, results2, by = "subIR_ID")  %>% 
      mutate(mech1_result = ifelse(is.na(mech1_result), 0, mech1_result),
             mech2_result = ifelse(is.na(mech2_result), 0, mech2_result),
             diff = mech2_result - mech1_result,
             colourDiff = ifelse(diff == 1, blueAccent,
                                 ifelse(diff == -1, redAccent,
                                        ifelse(diff == 0, purpleAccent, grey15K))))
  })
  
  
  # plot individual subIR matrix -------------------------------------------------
  output$indivSubIR = renderPlot({
    filteredDF = filter_dotMatrix()
    
    if(nrow(filteredDF) > 0){
      # Find the position to put the y-labels
      yLab = nrow(filteredDF) + 0.5
      
      resultsPlot = ggplot(filteredDF, aes(y = subIR_ID)) +
        geom_point(aes(x = -1), fill = grey15K, 
                   size = 10, colour = grey90K, shape = 21) +
        geom_point(aes(x = 0), fill = grey15K,
                   size = 10, colour = grey90K, shape = 21) +
        geom_point(aes(x = 1), fill = grey15K,
                   size = 10, colour = grey90K, shape = 21) +
        geom_point(aes(x = diff, fill = colourDiff), 
                   size = 10, colour = grey90K, 
                   alpha = 0.75, shape = 21) + 
        annotate('text', x = -1, y = yLab, label = input$mech1, 
                 hjust = 1, colour = grey70K) +
        annotate('text', x = 0, y = yLab, label = 'both', 
                 hjust = 0.5, colour = grey70K) +
        annotate('text', x = 1, y = yLab, label = input$mech2, 
                 hjust = 0, colour = grey70K) +
        scale_fill_identity() +
        scale_x_continuous(breaks = c(-1, 0, 1),
                           limits = c(-1.25, 1.25),
                           labels = c(input$mech1, 'both', input$mech2)) +
        theme_void() +
        theme(text = element_text(colour = grey70K, size = 12),
              axis.text.x = element_text(size = 8),
              axis.text.y = element_text(size = 12, hjust = 1),
              plot.margin = unit(c(yAxis_pad/2, yAxis_pad/4, yAxis_pad/4, yAxis_pad), 'cm')
        )
      
      gt <- ggplot_gtable(ggplot_build(resultsPlot))
      gt$layout$clip[gt$layout$name == "panel"] <- "off"
      grid.draw(gt)
      
      return(gt)
    }
  })
  
  
  
  # filter the data for the dot Matrix of districts -----------------------------------------
  
  filter_dotDist = reactive({
    
    dists1 = df %>% 
      # -- Filter out mechanisms based on user input --
      filter(result %in% results(), # remove results if unchecked by user
             Province == selRegion, # limit to the selected region
             mechanism %in% c(input$mech1)) %>% # select the first mechanism from the dropdown menu
      # -- Group by district and count --
      group_by(mechanism, District) %>% 
      summarise(num = n()) %>% 
      mutate(mech1_dist = num > 0) %>% # convert to binary
      ungroup() %>% 
      select(District, mech1_dist)
    
    dists2 = df %>% 
      # -- Filter out mechanisms based on user input --
      filter(result %in% results(), # remove results if unchecked by user
             Province == selRegion, # limit to the selected region
             mechanism %in% c(input$mech2)) %>% # select the second mechanism from the dropdown menu
      # -- Group by district and count --
      group_by(mechanism, District) %>% 
      summarise(num = n()) %>% 
      mutate(mech2_dist = num > 0) %>% # convert to binary
      ungroup() %>% 
      select(District, mech2_dist)
    
    
    
    
    full_join(dists1, dists2, by = "District")  %>% 
      mutate(mech1_dist = ifelse(is.na(mech1_dist), 0, mech1_dist),
             mech2_dist = ifelse(is.na(mech2_dist), 0, mech2_dist),
             diff = mech2_dist - mech1_dist,
             colourDiff = ifelse(diff == 1, blueAccent,
                                 ifelse(diff == -1, redAccent,
                                        ifelse(diff == 0, purpleAccent, grey15K))))
  })
  
  
  # plot individual district matrix -------------------------------------------------
  output$indivDist = renderPlot({
    filteredDF = filter_dotDist()
    
    if(nrow(filteredDF) > 0){
      # Find the position to put the y-labels
      yLab = nrow(filteredDF) + 0.5
      
      distPlot = ggplot(filteredDF, aes(y = District)) +
        geom_point(aes(x = -1), fill = grey15K, 
                   size = 10, colour = grey90K, shape = 21) +
        geom_point(aes(x = 0), fill = grey15K,
                   size = 10, colour = grey90K, shape = 21) +
        geom_point(aes(x = 1), fill = grey15K,
                   size = 10, colour = grey90K, shape = 21) +
        geom_point(aes(x = diff, fill = colourDiff), 
                   size = 10, colour = grey90K, 
                   alpha = 0.75, shape = 21) + 
        annotate('text', x = -1, y = yLab, label = input$mech1, 
                 hjust = 1, colour = grey70K) +
        annotate('text', x = 0, y = yLab, label = 'both', 
                 hjust = 0.5, colour = grey70K) +
        annotate('text', x = 1, y = yLab, label = input$mech2, 
                 hjust = 0, colour = grey70K) +
        scale_fill_identity() +
        scale_x_continuous(breaks = c(-1, 0, 1),
                           limits = c(-1.25, 1.25),
                           labels = c(input$mech1, 'both', input$mech2)) +
        theme_void() +
        theme(text = element_text(colour = grey70K, size = 12),
              axis.text.x = element_text(size = 8),
              axis.text.y = element_text(size = 12, hjust = 1),
              plot.margin = unit(c(yAxis_pad/2, yAxis_pad/4, yAxis_pad/4, yAxis_pad*4), 'cm')
        )
      
      gt <- ggplot_gtable(ggplot_build(distPlot))
      gt$layout$clip[gt$layout$name == "panel"] <- "off"
      grid.draw(gt)
      
      return(gt)
    }
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
    
    left_join(map1, rw.df, by = 'District')
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
    
    left_join(map2, rw.df, by = 'District')
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






