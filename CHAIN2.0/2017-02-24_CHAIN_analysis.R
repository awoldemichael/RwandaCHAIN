# RWA_CHAINanalysis_2017-02-24
# Laura Hughes, lhughes@usaid.gov


# import pkgs -------------------------------------------------------------

library(dplyr)
library(tidyr)
library(llamar)
library(stringr)
library(geocenter)
library(data.table)
library(ggplot2)
library(RColorBrewer)


# import data -------------------------------------------------------------

df = read.csv('~/Documents/USAID/Rwanda/CHAIN/datain/2017-02-23_Rwanda - CHAIN Programs.csv')
# geo data
source("~/GitHub/Rwanda/R/RWA_WFP_05_importGeo.R")


# COORDINATION: find overlapping data ---------------------------------------------------


sect_interv = df %>% 
  select(Intervention, Sector, District, Province, Impl..Partner) %>% 
  # distinct() %>% 
  group_by(Intervention, Sector, District, Province) %>% 
  summarise(ct = n(),
            ips = paste(Impl..Partner, collapse = ", ")) 


overlap = sect_interv %>% 
  filter(ct > 1) %>% 
  arrange(desc(ct))

pct_dup = nrow(overlap) / nrow(sect_interv)

pct_maj_dup = nrow(sect_interv %>% filter(ct > 2)) / nrow(sect_interv)

# hist of number of unique sector-intervention combos.  Most are unique.
ggplot(sect_interv, aes(x = ct)) +
  geom_histogram(binwidth = 1) +
  theme_ygrid() +
  ylab("") +
  ggtitle("Number of partners working in a given sector (geography) and intervention (technical area)")


# quick map + plot of the largest overlaps --------------------------------


# COLLABORATION: find overlapping tech areas, sectors ---------------------

sect_tech = df %>% 
  select(Technical.Area...Program, Sector, District, Province, Impl..Partner, Intervention) %>% 
  group_by(Technical.Area...Program, Sector, District, Province, Impl..Partner) %>% 
  summarise(interv = paste(Intervention, collapse = " * ")) %>% 
  group_by(Technical.Area...Program, Sector, District, Province) %>% 
  summarise(ct = n(),
            activ = paste(paste(Impl..Partner, interv, sep = ": "), collapse = ", "),
            ips = paste(Impl..Partner, collapse = ", ")) %>% 
  arrange(desc(ct))

ggplot(sect_tech, aes(x = ct)) +
  geom_histogram(binwidth = 1) +
  theme_ygrid() +
  ylab("") +
  ggtitle("Number of partners working in a given sector (geography) and technical area")

overlap_tech = sect_tech %>% 
  filter(ct > 1) %>% 
  arrange(desc(ct))

nrow(sect_tech %>% filter(ct>1)) / nrow(sect_tech)
nrow(sect_tech %>% filter(ct>2)) / nrow(sect_tech)


# COLLABORATION: overlap matrix -------------------------------------------
test = df %>% filter(Sector %like% 'Kabarondo', Technical.Area...Program %like% 'Health')

ggplot(test, aes(x = Intervention, y = Impl..Partner)) +
  coord_flip() +
  geom_point(color = 'dodgerblue', size = 6) +
  theme_xylab()



# Analysis: Who should coordinate w/ whom? --------------------------------
sect_ids = RWA_admin3$df %>% select(Province, District, Sector, Sect_ID) %>% distinct()

df = left_join(df, sect_ids)


full_overlap = df %>% 
  select(Sect_ID, Impl..Partner, Technical.Area...Program) %>% 
  distinct() %>% 
  filter(!is.na(Impl..Partner)) %>% 
  rowwise() %>% 
  mutate(isActive = 1,
         id = paste(Sect_ID, Impl..Partner, Technical.Area...Program, collapse = ","))

sectors = unique(df$Technical.Area...Program)
sectors = sectors[!is.na(sectors)]

all_overlap = NULL

for(selSector in sectors){
  
  overlap_lookup = df %>% 
  filter(Technical.Area...Program %like% selSector) %>% 
  select(Sect_ID, Impl..Partner) %>% 
  distinct() %>% 
  rowwise() %>% 
  mutate(isActive = 1,
         projID = paste(Sect_ID, Impl..Partner, collapse = ",")) %>%
  ungroup() 

overlap_matrix = overlap_lookup %>% 
  filter(!is.na(Impl..Partner)) %>% 
  select(Sect_ID, Impl..Partner, isActive) %>%
  spread(Sect_ID, isActive)

  # Convert to a matrix
  df2Dot = as.matrix(overlap_matrix %>% ungroup() %>% select(-Impl..Partner))
  
  # replace all NAs with 0
  df2Dot[is.na(df2Dot)] = 0
  
  # Create matrix transpose
  dfTranspose = t(df2Dot) 
  
  # Calculate dot product == sum of where the two values are both 1. 
  # Thanks @nada
  overlapMatrix =  df2Dot %*% dfTranspose 
  
  # Remove half the matrix since it's duplicative
  # overlapMatrix[lower.tri(overlapMatrix, diag = TRUE)] = NA
  
  # collapse back to the IP level
  colnames(overlapMatrix) = overlap_matrix$Impl..Partner
  overlapMatrix = data.frame(ip1 = overlap_matrix$Impl..Partner, overlapMatrix)
  

  
  overlapMatrix = gather(overlapMatrix, ip2, numDist, -ip1) %>% 
    mutate(sector = selSector)
  
  all_overlap = bind_rows(overlapMatrix, all_overlap)
}


all_overlap_tot = all_overlap %>% 
  group_by(ip1, ip2) %>% 
  summarise(total = sum(numDist)) %>% 
  ungroup() %>% 
  arrange((total))

overlap_levels = c("Catholic Relief Services",
                   "SNV",
                   "Society for Family Health",
                   "AEE/Rwanda",                                     
                   "Association Francois-Xavier Bagnoud (FXB)/Rwanda",
                   "Caritas/Rwanda", 
                   "International Potato Center",  
                   "Global Communities",                              
                   "Harvard School of Public Health",                 
                   "Harvest Plus",                                    
                   "Development Alternatives Inc. (DAI)"                   
)

overlap_levels2=c("Catholic.Relief.Services",
"SNV",
"Society.for.Family.Health",
"AEE.Rwanda",
"Association.Francois.Xavier.Bagnoud..FXB..Rwanda",
"Caritas.Rwanda",
"International.Potato.Center",

"Global.Communities",
"Harvard.School.of.Public.Health",
"Harvest.Plus",
"Development.Alternatives.Inc...DAI."
)
# Refactorize levels
all_overlap_tot$ip1 = factor(all_overlap_tot$ip1,
                             levels = rev(overlap_levels))

all_overlap_tot$ip2 = factor(all_overlap_tot$ip2,
                             levels = (overlap_levels2))

all_overlap_tot = map_colour_text(all_overlap_tot, 'total', brewer.pal(9, "Purples"),
                                  limits = c(1, max(all_overlap_tot$total))) 

all_overlap_tot = all_overlap_tot %>% 
  filter(total < 100)

ggplot(all_overlap_tot, aes(x = ip2, y = ip1, size = total, fill = total)) +
         geom_point(shape = 21) +
    geom_text(aes(label = total, colour = text_colour),
              size  = 4) +
  scale_colour_identity() +
    scale_size_continuous(range = c(4, 14),
                          limits = c(1, max(all_overlap_tot$total))) +
         scale_fill_gradientn(colours = brewer.pal(9, "Purples"),
                              limits = c(1, max(all_overlap_tot$total))) +
         theme_xygrid() +
  # coord_flip()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


save_plot('chain_overlap_2017-03-02.pdf', width = 10, height = 9)

# Facet by sector
ggplot(all_overlap, aes(x = ip1, y = ip2, size = numDist, fill = numDist)) +
  geom_point(shape = 21) +
  geom_text(aes(label = numDist, colour = 'white'),
            size  = 4) +
  scale_colour_identity() +
  scale_size_continuous(range = c(4, 14),
                        limits = c(1, max(all_overlap$numDist))) +
  scale_fill_gradientn(colours = brewer.pal(9, "Purples"),
                       limits = c(1, max(all_overlap$numDist))) +
  theme_xygrid() +
  facet_wrap(~sector) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
  # # Remove half the matrix since it's duplicative
  # overlapMatrix[lower.tri(overlapMatrix, diag = TRUE)] = NA
  # 
  # # Rename to be the IP names and reshape long
  # colnames(overlapMatrix) = overlap_matrix$Impl..Partner
  # 
  # overlapMatrix = data.frame(ip1 = overlap_matrix$Impl..Partner, overlapMatrix)
  # 
  # overlapMatrix = gather(overlapMatrix, ip2, numDist, -ip1) %>% 
  #   mutate(ip2 = str_replace(ip2, '\\.', ' '), #Remove . introduced by rownames
  #          colourText = ifelse(is.na(numDist), NA,
  #                              ifelse(numDist > median(numDist, na.rm = TRUE), grey15K, grey90K))
  #   ) #
  # 
  # # Refactorize levels
  # overlapMatrix$ip2 = factor(overlapMatrix$ip2, 
  #                            levels = rev(overlapMatrix$ip2))
  # 
  # ggplot(overlapMatrix, aes(x = ip1, y = ip2, 
  #                           fill = numDist, size = numDist)) +
  #   geom_point(shape = 21) +
  #   # geom_text(aes(label = numDist, colour = colourText),
  #             # size  = 4) +
  #   # geom_text(aes(label = ip2), colour = grey70K,
  #   # hjust = 1, nudge_x = 0.1,
  #   # size  = 5, data = overlapMatrix) +
  #   scale_size_continuous(range = c(4, 14),
  #                         limits = c(1, max(all_overlap$total))) +
  #   scale_colour_identity() +
  #   scale_fill_gradientn(colours = brewer.pal(9,'YlGn')[2:9]) +
  #   theme_void() +
  #   theme(text = element_text(colour = grey70K, size = 16),
  #         line = element_line(colour = grey70K, size = 0.15, linetype = 1, lineend = 'butt'),
  #         axis.line = element_line(),
  #         axis.ticks = element_blank(),
  #         panel.grid.major = element_line(colour = grey70K), 
  #         panel.grid.minor = element_line(colour = grey70K), 
  #         axis.text.x = element_text(),
  #         axis.text.y = element_text(),
  #         legend.position = 'none')
  
# LEARNING: Who’s the expert? ---------------------------------------------


expertise = df %>% 
  group_by(Province, District, Sector, Technical.Area...Program, Impl..Partner, Intervention) %>% 
  distinct() %>% 
  group_by(Technical.Area...Program, Intervention, Impl..Partner) %>% 
  summarise(ct = n()) %>% 
  arrange(Impl..Partner, desc(ct))


# data by focus area ------------------------------------------------------
tot_area = df %>% group_by(Technical.Area...Program) %>% summarise(ct = n())

ggplot(tot_area, aes(x = forcats::fct_reorder(Technical.Area...Program, ct), y = ct, 
               fill = Technical.Area...Program)) +
  geom_bar(stat = 'identity', colour = grey90K, size = 0.2) +
  coord_flip() +
  theme_xgrid(projector = T) +
  ylab(" ") +
  theme(plot.margin = unit(c(0.2,1,0.2,0.2), "cm")) +
  ggtitle("Number of unique interventions per sector")

interv = df %>% group_by(Intervention) %>% summarise(ct=n()) %>% arrange(desc(ct))


ggplot(interv, aes(x = forcats::fct_reorder(Intervention, ct), y = ct, 
                     fill = Intervention)) +
  geom_bar(stat = 'identity', colour = grey90K, size = 0.2) +
  coord_flip() +
  theme_xgrid(projector = T) +
  ylab(" ") +
  ggtitle("Number of unique interventions per sector")



# District-level EG maps --------------------------------------------------
eg_dist = df %>% group_by(District, Impl..Partner, Technical.Area...Program) %>%
  distinct() %>%
  filter(Technical.Area...Program %like% 'Econ') %>% 
  rename(ip = Impl..Partner) %>% 
  summarise(n = n())
  
eg_map = full_join(RWA_admin2$df, eg_dist)

geocenter::plot_map(eg_map, 'n') + facet_wrap(~ip) + scale_colour_gradientn(colours = brewer.pal())