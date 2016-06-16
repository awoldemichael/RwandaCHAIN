# Define sidebar for inputs -----------------------------------------------

sidebar <- dashboardSidebar(disable = TRUE
                            #   
                            #   
                            #   checkboxGroupInput("countryList",label = NULL, inline = FALSE,
                            #                      choices = countries,
                            #                      selected = countries),
                            #   
                            #   # -- Sidebar icons --
                            #   sidebarMenu(
                            #     # Setting id makes input$tabs give the tabName of currently-selected tab
                            #     id = "tabs",
                            #     menuItem("each country", tabName = "indivTab", icon = icon("crosshairs")),
                            #     menuItem("maps", tabName = "choroTab", icon = icon("map-o")),
                            #     menuItem("TFR over time", tabName = "plot", icon = icon("bar-chart")),
                            #     menuItem("change in TFR rates", tabName = "rateTab", icon = icon("line-chart"))
                            #   )
)


# Header ------------------------------------------------------------------
header <- dashboardHeader(
  title = "Rwanda CHAIN programs" 
)



# Body --------------------------------------------------------------------

body <- dashboardBody(
  fluidRow('West', indivRegionUI('west')),
  # -- Each tab --
  # tabItems(
  #   
  #   # -- Individual region plots --
  #   # tabItem(tabName = 'indivTab',
  #           # fluidRow("hjf"
  #             # tabBox(
  #               # tabPanel('West', 
  #                        # indivRegionUI('west'))
  #             )),
  #   tabItem(tabName = 'main',            
  #           
            # -- Filters for the map --
            fluidRow(column(2, radioButtons('comparison', label = NULL, choices = c('by partner' = 'IP', 'by result' = 'IR'),
                                            selected = 'IP', inline = TRUE)),
                     column(2, selectizeInput('filterIP', label = 'partner', multiple = TRUE,
                                              selected = 'all',
                                              choices = c('all', unique(as.character(df$IP))))),
                     column(2, selectizeInput('filterIM', label = 'mechanism', multiple = TRUE, 
                                              selected = 'all',
                                              choices = c('all', unique(as.character(df$mechanism))))),
                     column(2, selectizeInput('filterIR', label = 'results', multiple = TRUE, 
                                              selected = 'all',
                                              choices = c('all', unique(as.character(df$Result)))))
            ),
            
            # -- plot maps --
            fluidRow(plotOutput('main'))
            
    )
  
  
  # Dashboard definition (main call) ----------------------------------------
  
  dashboardPage(
    title = "CHAIN donor coordination",  
    header,
    sidebar,
    body
  )