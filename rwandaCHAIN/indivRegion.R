indivRegionUI = function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(column(6,plotOutput(ns('indivPlot'))),
             column(6, plotOutput(ns('indivChoro')))),
    
    fluidRow(column(6,plotOutput(ns('indivRegion')))
    ),
    fluidRow(imageOutput(ns('indivFooter'), width = '90%'))
  )
}

indivRegion = function(input, output, session, df, selRegion){
  
  filterDF = reactive({
    df %>% 
      filter()
  })
  
  output$indivFooter = renderImage({
    return(list(
      src = "img/footer_Rw.png",
      width = '100%',
      filetype = "image/png",
      alt = "Plots from USAID's GeoCenter"
    ))
  }, deleteFile = FALSE)
  
  
  output$indivPlot = renderPlot({
    
    # Filter down the data
    filteredDF = filterDF()
    
    ggplot(mtcars, aes(x = mpg, y = cyl)) +
      geom_point()
  })
  
  output$indivChoro = renderPlot({
    ggplot(mtcars, aes(x = mpg, y = cyl)) +
      geom_point()
  })
  
  
  
  
  output$indivRegion = renderPlot({
    filteredDF = filterDF() %>% 
      filter(country == selRegion)
    
    ggplot(mtcars, aes(x = mpg, y = cyl)) +
      geom_point()
    
  }, 
  height = 150)
}