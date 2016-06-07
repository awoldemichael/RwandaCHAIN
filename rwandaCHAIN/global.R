# Global data for 
# Laura Hughes, lhughes@usaid.gov, 6 June 2016

# Set up the app ----------------------------------------------------------
library(dplyr)
library(tidyr)
library(ggplot2)
library(shiny)
library(shinydashboard)
library(stringr)
library(llamar)
library(choroplethr)
library(choroplethrMaps)
library(RColorBrewer)


# import data -------------------------------------------------------------
df = read.csv('~/Documents/USAID/Rwanda/CHAIN/dataout/RW_projects.csv')

rwanda = choroplethrAdmin1::get_admin1_regions('rwanda')
