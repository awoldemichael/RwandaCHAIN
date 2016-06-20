# Define sidebar for inputs -----------------------------------------------

sidebar <- dashboardSidebar(
  # -- Select results --
  checkboxGroupInput('filterResult',label = 'intended result', inline = FALSE,
                     choices = c('improved health practices (subpurpose 1)' = 'Increased awareness of, access to, and demand for high-impact health practices',
                                 'vulnerable population protection (subpurpose 2)' = 'Improved protection of vulnerable populations against adverse circumstances',
                                 'improved nutrition (subpurpose 3)' = 'Increase nutrition knowledge and adoption of appropriate nutrition and hygiene practices',
                                 'CSO/GOR performance (subpurpose 4)' = 'Improved performance and engagement by CSOs and GOR entities'),
                     selected = unique(df$result)),
  
  # -- Select mechanisms --
  checkboxGroupInput('filterMech',label = 'mechanism', inline = FALSE,
                     choices = mechanisms,
                     selected = mechanisms),
  # -- Select IPs --
  checkboxGroupInput("filterIP",label = 'partner', inline = FALSE,
                     choices = ips,
                     selected = ips)
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
  
  
  # -- Each tab --
  tabsetPanel(
    
    
    tabPanel('by district',
             
             # -- plot maps --
             column(7, fluidRow(h3('Number of Mechanisms by District')),
                    fluidRow(leafletOutput('main', height = heightMap,
                                           width = widthMap))),
             column(5, fluidRow(h3('Number of Unique Mechanisms by Province')),
                    fluidRow(ggvisOutput('numByProv'))),
             fluidRow(imageOutput('footer'))
    ),
    tabPanel('by result',
             fluidRow(column(4,indivResultUI('subIR1')),
                      column(4,indivResultUI('subIR2'))),
             fluidRow(column(4,indivResultUI('subIR3')),
                      column(4,indivResultUI('subIR4'))),
             fluidRow(imageOutput('footer2'))),
    
    # -- Individual region plots --
    tabPanel('Eastern Province',
             fluidRow(indivRegionUI('east'))),
    tabPanel('Kigali City',
             fluidRow(indivRegionUI('kigali'))),
    tabPanel('Northern Province',
             fluidRow(indivRegionUI('north'))),
    tabPanel('Southern Province',
             fluidRow(indivRegionUI('south'))),
    tabPanel('Western Province',
             fluidRow(indivRegionUI('west')))
  ))

# Dashboard definition (main call) ----------------------------------------

dashboardPage(
  title = "CHAIN donor coordination",  
  header,
  sidebar,
  body
)