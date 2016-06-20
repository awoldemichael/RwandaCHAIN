# Global data for 
# Laura Hughes, lhughes@usaid.gov, 6 June 2016

# Set up the app ----------------------------------------------------------
# -- data manipulation --
library(dplyr)
library(tidyr)
library(data.table)

# -- plotting --
library(ggvis)
library(ggplot2)
library(RColorBrewer)

# -- shiny --
library(shiny)
library(shinydashboard)

# -- mapping --
library(rgeos)
library(rgdal)
library(maptools)
library(leaflet)

# import data -------------------------------------------------------------
# -- IP data --
df = read.csv('data/RW_projects_adm2_2016-06-14.csv',
              stringsAsFactors = FALSE)

# -- Map data --
rw_adm2 = readOGR(path.expand("data/"), layer="District_Boundary_2006_simpl")

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
grey70K = "#6d6e71"
baseColour = grey15K = "#DCDDDE"
labelColour = grey90K = "#414042"
strokeColour = grey90K

redAccent = '#e41a1c'
blueAccent = '#377eb8'
purpleAccent = '#984ea3'

colourProv = c('#e41a1c', '#377eb8', 
               '#4daf4a', '#984ea3', '#ff7f00')

categPal = colorFactor(palette = colourProv, domain = provinces)
contPal = colorNumeric(palette = 'YlGnBu', domain = 0:20)

# sizes -------------------------------------------------------------------
widthMap = '750px'
heightMap = '675px'
circleScaling = 1000


# Source files ------------------------------------------------------------
source('indivRegion.R')
source('indivResults.R')
