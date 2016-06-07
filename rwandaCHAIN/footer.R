footerUI = function(id){
  ns <- NS(id)
  
  tagList(
    fluidRow(imageOutput('footer', width = '100%'))
  )
}

footer = function(input, output, session){
  output$footer = renderImage({
    return(list(
      src = "img/footer_Rwanda.png",
      width = '100%',
      filetype = "image/png",
      alt = "Plots from USAID's GeoCenter"
    ))
  }, deleteFile = FALSE)
}