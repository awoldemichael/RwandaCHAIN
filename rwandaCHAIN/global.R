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
library(rgdal)
library(maptools)
library(rgeos)
library(RColorBrewer)
library(data.table)
library(leaflet)

# import data -------------------------------------------------------------
# -- IP data --
df = read.csv('~/Documents/USAID/Rwanda/CHAIN/dataout/RW_projects_adm2_2016-06-14.csv',
              stringsAsFactors = FALSE)

# -- Map data --
setwd('~/Documents/USAID/Rwanda/data in/Rwanda_Admin2/')
rw_adm2 = readOGR(dsn=".", layer="District_Boundary_2006")

rw_adm2@data$id = rownames(rw_adm2@data)
rw.points = fortify(rw_adm2, region="id")
rw.df = plyr::join(rw.points, rw_adm2@data, by="id")


# Set limits for bounding box ---------------------------------------------
spacer = 0.05

minLon = rw_adm2@bbox['x', 'min'] * (1-spacer)
minLat = rw_adm2@bbox['y', 'min'] * (1-spacer)
maxLon = rw_adm2@bbox['x', 'max'] * (1+spacer)
maxLat = rw_adm2@bbox['y', 'max'] * (1+spacer)


# Pull out choices for provinces, IPs, mechanisms -------------------------
provinces = unique(rw_adm2$Prov_Name)

mechanisms = sort(unique(df$mechanism))

ips = sort(unique(df$IP))

# Define colors for maps --------------------------------------------------
baseColour = grey15K
labelColour = grey90K
strokeColour = grey90K

categPal = colorFactor(palette = c('#e41a1c', '#377eb8', 
                       '#4daf4a', '#984ea3', '#ff7f00'), domain = provinces)


# sizes -------------------------------------------------------------------
widthMap = '750px'
heightMap = '675px'
circleScaling = 1000


# Source files ------------------------------------------------------------
# source('indivRegion.R')
