# Define sidebar for inputs -----------------------------------------------

sidebar <- dashboardSidebar(
  # -- Select results --
  checkboxGroupInput('filterResult',label = 'intended result', inline = FALSE,
                     choices = c('improved health practices' = 'Increased awareness of, access to, and demand for high-impact health practices',
                                 'vulnerable population protection' = 'Improved protection of vulnerable populations against adverse circumstances',
                                 'improved nutrition' = 'Increase nutrition knowledge and adoption of appropriate nutrition and hygiene practices',
                                 'CSO/GOR performance' = 'Improved performance and engagement by CSOs and GOR entities'),
                     selected = unique(df$result)),
  
  # -- Select mechanisms --
  checkboxGroupInput('filterMech',label = 'mechanism', inline = FALSE,
                     choices = mechanisms,
                     selected = mechanisms),
  # -- Select IPs --
  checkboxGroupInput("filterIP",label = 'partner', inline = FALSE,
                     choices = ips,
                     selected = ips)
  
  # selectizeInput('filterIP', label = 'partner', multiple = TRUE,
  #                selected = ips,
  #                choices = ips),
  
  
  
  # -- Sidebar icons --
  # sidebarMenu(
  #   # Setting id makes input$tabs give the tabName of currently-selected tab
  #   id = "tabs",
  #   menuItem("each country", tabName = "indivTab", icon = icon("crosshairs")),
  #   menuItem("maps", tabName = "choroTab", icon = icon("map-o")),
  #   menuItem("TFR over time", tabName = "plot", icon = icon("bar-chart")),
  #   menuItem("change in TFR rates", tabName = "rateTab", icon = icon("line-chart"))
  # )
)


# Header ------------------------------------------------------------------
header <- dashboardHeader(
  title = "Rwanda CHAIN programs" 
)



# Body --------------------------------------------------------------------

body <- dashboardBody(
  # -- Import custom CSS --
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "leaflet.css")),
  # fluidRow('West', indivRegionUI('west')),
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
  # fluidRow(column(2, radioButtons('comparison', label = NULL, choices = c('by partner' = 'IP', 'by result' = 'IR'),
  # selected = 'IP', inline = TRUE)),
  # column(2, selectizeInput('filterIP', label = 'partner', multiple = TRUE,
  # selected = 'all',
  # choices = c('all', unique(as.character(df$IP))))),
  # column(2, selectizeInput('filterIM', label = 'mechanism', multiple = TRUE, 
  # selected = 'all',
  # choices = c('all', unique(as.character(df$mechanism))))),
  # column(2, selectizeInput('filterIR', label = 'results', multiple = TRUE, 
  # selected = 'all',
  # choices = c('all', unique(as.character(df$result)))))
  # ),
  
  # -- plot maps --
  column(7, fluidRow(h3('Number of Mechanisms by District')),
         fluidRow(leafletOutput('main', height = heightMap,
                                width = widthMap))),
  column(5, fluidRow(h3('Number of Mechanisms by Province')),
         fluidRow(ggvisOutput('numByProv')))
  
)


# Dashboard definition (main call) ----------------------------------------

dashboardPage(
  title = "CHAIN donor coordination",  
  header,
  sidebar,
  body
)