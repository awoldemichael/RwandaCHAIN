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
library(data.table)

# import data -------------------------------------------------------------
# -- IP data --
df = read.csv('~/Documents/USAID/Rwanda/CHAIN/dataout/RW_projects_adm2_2016-06-14.csv')

# -- Map data --
setwd('~/Documents/USAID/Rwanda/data in/Rwanda_Admin2/')
rw_adm2 = readOGR(dsn=".", layer="District_Boundary_2006")

# Source files ------------------------------------------------------------
# source('indivRegion.R')
