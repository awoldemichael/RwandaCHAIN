
# Create 4x small multiples for each of the sub-IRs -----------------------
# 20 June 2016
# Laura Hughes, lhughes@usaid.gov

# ui code -----------------------------------------------------------------

indivResultUI = function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(plotOutput(ns('resultsMap')))
    
    # fluidRow(imageOutput(ns('indivFooter2'), width = '100%'))
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
  
  output$resultsMap = renderPlot({
    ggplot(mtcars, aes(x=mpg, y = cyl)) +
      geom_point()
  })
  
  
  # -- fin --
}






