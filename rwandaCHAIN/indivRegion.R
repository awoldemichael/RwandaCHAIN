# ui code -----------------------------------------------------------------

indivRegionUI = function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(column(6, imageOutput(ns('indivMap'))),
             column(6, plotOutput(ns('indivRegion')))),
    
    fluidRow(column(6,plotOutput(ns('indivPlot')))
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
           mechanism %in% mechanisms,
           result %in% results,
           IP %in% ips) %>%
      # -- Group by District and count --
      group_by(Province, District, shortName, subIR_ID) %>% 
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
  
  output$indivMap = renderImage({
    return(list(
      src = paste0("img/rwanda_", selRegion, '.png'),
      width = '100%',
      filetype = "image/png",
      alt = "Plots by USAID's GeoCenter"
    ))
  }, deleteFile = FALSE)
  
  
  output$indivRegion = renderPlot({
    filteredDF = filter_byResult()
    
    
    ggplot(filteredDF, aes(x = subIR_ID,
                           y = shortName,
                           fill = num)) +
      geom_tile() +
      facet_wrap(~District) +
      theme_xylab() +
      scale_fill_gradientn(colours = brewer.pal(9, 'Blues'))
    
  })
  
}




