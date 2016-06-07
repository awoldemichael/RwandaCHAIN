shinyServer(
  function(input, output, session) {
    
    filterDF = reactive({
      df %>% 
        filter(Result %in% input$IR)
    })
    
  })