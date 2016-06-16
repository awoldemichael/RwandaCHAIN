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
# library(choroplethr)
# library(choroplethrMaps)
library(rgdal)
library(maptools)
library(rgeos)
library(RColorBrewer)
library(data.table)
library(leaflet)

# import data -------------------------------------------------------------
# -- IP data --
df = read.csv('~/Documents/USAID/Rwanda/CHAIN/dataout/RW_projects_adm2_2016-06-14.csv')

# -- Map data --
setwd('~/Documents/USAID/Rwanda/data in/Rwanda_Admin2/')
rw_adm2 = readOGR(dsn=".", layer="District_Boundary_2006")

rw_adm2@data$id = rownames(rw_adm2@data)
rw.points = fortify(rw_adm2, region="id")
rw.df = plyr::join(rw.points, rw_adm2@data, by="id")


# Set limits for bounding box ---------------------------------------------
spacer = 0.05

minLon = rw@bbox['x', 'min'] * (1-spacer)
minLat = rw@bbox['y', 'min'] * (1-spacer)
maxLon = rw@bbox['x', 'max'] * (1+spacer)
maxLat = rw@bbox['y', 'max'] * (1+spacer)

# Source files ------------------------------------------------------------
# source('indivRegion.R')
