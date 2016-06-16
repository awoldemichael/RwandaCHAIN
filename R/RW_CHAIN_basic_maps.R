ggplot(df2, aes(x = District)) +
  geom_bar(stat = 'count') +
  facet_wrap(~IP)



# Maps! Basic names -------------------------------------------------------
colourRegions = '#fc8d59'
colourLakes = '#a6cee3'


x = ggplot(adm1.df) + 
  aes(x = long, y = lat) +
  geom_polygon(aes(group = group),
               fill = grey30K) +
  geom_path(aes(group = group),
            colour = 'white',
            data = rw.df,
            size = 0.1) +
  geom_path(aes(group = group, colour = id),
            size = 0.2) +
  geom_polygon(aes(group = group), #lakes
               fill = colourLakes,
               data = lakes.df) +
  coord_equal() +
  theme_blank() +
  scale_colour_brewer(palette = 'Set1') +
  # scale_colour_manual(values =c('Northern Province' = '#377eb8',
  # 'Kigali City' ='#e41a1c',
  # 'Western Province' = '#ff7f00',
  # 'Southern Province' = '#984ea3',
  # 'Eastern Province' = '#4daf4a')) +
  geom_text(aes(x = long, y = lat, label = district),
            data = rw.centroids,
            colour = grey90K,
            size = 1.2) +
  geom_text(aes(x = long, y = lat, label = province),
            data = adm1.centroids,
            colour = grey90K,
            size = 2)

ggsave('~/Documents/USAID/Rwanda/CHAIN/plots/rwanda_labeled_raw.pdf', 
       width = 5, height = 3.5,
       bg = 'transparent',
       paper = 'special',
       units = 'in',
       useDingbats=FALSE,
       compress = FALSE,
       dpi = 300)

# FtF ---------------------------------------------------------------------
df_adm2 = df_full %>% 
  filter(isDistrict == 1, 
         isSector == 1) %>% 
  select(-Sector, -Sect_ID, -isSector)


rw.df2 = full_join(rw.df, df_adm2, by = c("Prov_ID", "Dist_ID", "District"))


y = rw.df2 %>% 
  filter(project %like% 'FTF')

x = ggplot(rw.df) + 
  aes(x = long, y = lat, group = group)+
  geom_polygon(fill = grey30K) +
  geom_polygon(fill = colourRegions, data = y) +
  geom_path(color="white", size = 0.1) +
  geom_polygon(aes(group = group), #lakes
               fill = colourLakes,
               data = lakes.df) +
  facet_wrap(~ mechanism) +
  coord_equal() +
  theme_blank()


ggsave('~/Documents/USAID/Rwanda/CHAIN/plots/ftf_raw.pdf', 
       width = 10, height = 7,
       bg = 'transparent',
       paper = 'special',
       units = 'in',
       useDingbats=FALSE,
       compress = FALSE,
       dpi = 300)



# Purple ------------------------------------------------------------------

y = rw.df2 %>% 
  filter(project %like% 'Purple')

x = ggplot(rw.df) + 
  aes(x = long, y = lat, group = group)+
  geom_polygon(fill = grey30K) +
  geom_polygon(fill = colourRegions, data = y) +
  geom_path(color="white", size = 0.1) +
  geom_polygon(aes(group = group), #lakes
               fill = colourLakes,
               data = lakes.df) +
  facet_wrap(~ mechanism) +
  coord_equal() +
  theme_blank()

ggsave('~/Documents/USAID/Rwanda/CHAIN/plots/purple_raw.pdf',
       width = 10, height = 7,
       bg = 'transparent',
       paper = 'special',
       units = 'in',
       useDingbats=FALSE,
       compress = FALSE,
       dpi = 300)



# Maps! (CHAIN)-------------------------------------------------------------------




df_CHAIN_dist = df_adm2 %>% 
  filter(project %like% 'CHAIN') %>% 
  group_by(mechanism, Province) %>% 
  summarise(numProj_adm1 = n()) %>%
  ungroup() %>% 
  group_by(mechanism) %>% 
  mutate(numProj = sum(numProj_adm1)) %>% 
  ungroup() %>% 
  arrange(desc(numProj))

orderCHAIN_dist = df_CHAIN_dist %>% 
  select(mechanism, numProj) %>% 
  distinct()

# Refactorize
df_adm2$mechanism = factor(df_adm2$mechanism,
                           levels = orderCHAIN_dist$mechanism)

df_adm2$Province = factor(df_adm2$Province, levels = c( 
  'Northern Province',
  'Kigali City',
  'Western Province',
  'Southern Province',
  'Eastern Province'))

rw.df2 = full_join(rw.df, df_adm2, by = c("Prov_ID", "Dist_ID", "District"))

y = rw.df2 %>% 
  filter(project %like% 'CHAIN')



x = ggplot(rw.df) + 
  aes(x = long, y = lat) +
  geom_polygon(aes(group = group),
               fill = grey30K) +
  geom_polygon(aes(group = group, fill = Province), 
               # fill = colourRegions,
               data = y) +
  geom_path(aes(group = group),
            color="white", size = 0.1) +
  geom_polygon(aes(group = group), #lakes
               fill = colourLakes,
               data = lakes.df) +
  facet_wrap(~ mechanism) +
  coord_equal() +
  theme_blank() +
  scale_fill_manual(values =c('Northern Province' = '#377eb8',
                              'Kigali City' ='#e41a1c',
                              'Western Province' = '#ff7f00',
                              'Southern Province' = '#984ea3',
                              'Eastern Province' = '#4daf4a'))
# geom_text(aes(x = long, y = lat, label = district), 
# data = rw.centroids,
# colour = grey90K,
# size = 0.7)

ggsave('~/Documents/USAID/Rwanda/CHAIN/plots/chain_raw.pdf', 
       width = 10, height = 7,
       bg = 'transparent',
       paper = 'special',
       units = 'in',
       useDingbats=FALSE,
       compress = FALSE,
       dpi = 300)


# CHAIN plots — # / Province ----------------------------------------------
mechanisms = unique(df_CHAIN_dist$mechanism)

# for (i in seq_along(mechanisms)){
# dfBar = df_CHAIN_dist %>% 
#   filter(mechanism == mechanisms[i])
dfBar = df_CHAIN_dist

# orderByMech = dfBar %>% 
#   arrange(numProj_adm1)

orderByMech =  c('Kigali City', 
                 'Northern Province',
                 'Western Province',
                 'Southern Province',
                 'Eastern Province')

dfBar$Province = factor(dfBar$Province, 
                        levels = orderByMech)


ggplot(dfBar, aes(x = Province, y = numProj_adm1, 
                  fill = Province, label = numProj_adm1)) +
  geom_bar(stat = 'identity') +
  coord_flip() +
  geom_text(colour = 'white', size = 4,
            nudge_y = -0.3, 
            family = 'Segoe UI') +
  scale_fill_manual(values =c('Northern Province' = '#377eb8',
                              'Kigali City' ='#e41a1c',
                              'Western Province' = '#ff7f00',
                              'Southern Province' = '#984ea3',
                              'Eastern Province' = '#4daf4a')) +
  theme_xylab() +
  facet_wrap(~mechanism) +
  theme(axis.title = element_blank(), 
        axis.text.x = element_blank())

ggsave(paste0('~/Documents/USAID/Rwanda/CHAIN/plots/chain_bar_raw.pdf'), 
       width = 9, height = 5,
       bg = 'transparent',
       paper = 'special',
       units = 'in',
       useDingbats=FALSE,
       compress = FALSE,
       dpi = 300)
# }

# CHAIN: # overall
ggplot(df_CHAIN_dist, aes(x = mechanism, y = 1, 
                          label = paste0(numProj, ' districts'), 
                          fill = numProj)) +
  geom_tile() +
  geom_text(colour = grey90K, family = 'Segoe UI', size = 3) +
  scale_fill_gradient(low = grey15K, high  = grey60K) +
  theme_labelsOnly()

ggsave(paste0('~/Documents/USAID/Rwanda/CHAIN/plots/chain_totalDist_raw.pdf'), 
       width = 6, height = 3,
       bg = 'transparent',
       paper = 'special',
       units = 'in',
       useDingbats=FALSE,
       compress = FALSE,
       dpi = 300)

# CHAIN by results --------------------------------------------------------
df_CHAIN = df_full %>% 
  filter(isDistrict == 1,
         project %like% 'CHAIN') %>% 
  select(-Sector, -Sect_ID, -isSector) %>% 
  group_by(Province, Prov_ID, 
           District, Dist_ID, result) %>% 
  summarise(numProj = n()) 

orderCHAIN = df_CHAIN %>% 
  ungroup() %>% 
  group_by(result) %>%
  mutate(numProj = sum(numProj)) %>% 
  ungroup() %>% 
  arrange(desc(numProj)) %>% 
  select(result, numProj) %>% 
  distinct()


# Refactorize
df_CHAIN$result = factor(df_CHAIN$result,
                         levels = orderCHAIN$result)

rwCHAIN = right_join(rw.df, df_CHAIN, by = c("Prov_ID", "Dist_ID", "District"))

x = ggplot(rw.df) + 
  aes(x = long, y = lat) +
  geom_polygon(aes(group = group),
               fill = grey30K) +
  geom_polygon(aes(group = group,
                   fill = numProj),
               data = rwCHAIN) +
  geom_path(aes(group = group),
            color= grey75K, size = 0.1) +
  geom_polygon(aes(group = group), #lakes
               fill = colourLakes,
               data = lakes.df) +
  facet_wrap(~ result) +
  coord_equal() +
  theme_blank() +
  scale_fill_gradientn(colours = brewer.pal(9, 'YlGnBu')) +
  geom_text(aes(x = long, y = lat, label = district), 
            data = rw.centroids,
            colour = grey90K,
            size = 0.7) +
  theme(strip.text = element_text(size = 5))

ggsave('~/Documents/USAID/Rwanda/CHAIN/plots/chain_byResult_raw.pdf', 
       width = 10, height = 7,
       bg = 'transparent',
       paper = 'special',
       units = 'in',
       useDingbats=FALSE,
       compress = FALSE,
       dpi = 300)


# Number of Results / IM:
numResults_byMech = df_full %>% 
  filter(isDistrict == 1,
         project %like% 'CHAIN') %>% 
  ungroup() %>% 
  select(mechanism, result) %>% 
  distinct() %>% 
  group_by(mechanism) %>% 
  summarise(num = n()) %>% 
  ungroup() %>% 
  arrange((num))

numResults_byMech$mechanism =
  factor(numResults_byMech$mechanism, numResults_byMech$mechanism)

ggplot(numResults_byMech, aes(y = num, 
                              x = mechanism,
                              label = num)) +
  geom_bar(stat = 'identity', 
           fill = grey50K) +
  geom_text(nudge_y = -0.3, 
            colour = 'white', size = 4,
            family = 'Segoe UI') +
  coord_flip() +
  theme_xgrid()

ggsave('~/Documents/USAID/Rwanda/CHAIN/plots/chain_numResults_raw.pdf', 
       width = 10, height = 4,
       bg = 'transparent',
       paper = 'special',
       units = 'in',
       useDingbats=FALSE,
       compress = FALSE,
       dpi = 300)


# Comparison of where work on CHAIN ---------------------------------------

colour1 = '#0868ac'
colour2 = '#ffff33'
colourLakes = '#deebf7'

rw_CHAIN_proj = rw.df2 %>% 
  filter(project %like% 'CHAIN')

mechanisms = unique(rw_CHAIN_proj$mechanism)

counter = 1
plot_list = list()

for (i in 1:7){
  for (j in 1:7){
    print(counter)
    
    y = rw_CHAIN_proj %>% 
      filter(mechanism == mechanisms[i])
    
    z = rw_CHAIN_proj %>% 
      filter(mechanism == mechanisms[j])
    
    p = ggplot(rw_CHAIN_proj) + 
      aes(x = long, y = lat, group = group)+
      geom_polygon(fill = grey15K) +
      geom_polygon(fill = colour1, alpha = 0.6, data = y) +
      geom_polygon(fill = colour2, alpha = 0.6, data = z) +
      geom_polygon(aes(group = group), #lakes
                   fill = colourLakes,
                   data = lakes.df) +
      geom_path(color="white", size = 0.1) +
      coord_equal() +
      theme_blank() +
      theme(title = element_text(size = 3)) +
      ggtitle(paste(mechanisms[i], mechanisms[j], sep = ' & '))
    
    plot_list[[counter]] = p
    
    
    ggsave(paste0('~/Documents/USAID/Rwanda/CHAIN/plots/chain_overlap_raw',
                  counter, '.pdf', collapse = ''),
           width = 3.5,
           height = 2,
           bg = 'transparent',
           paper = 'special',
           units = 'in',
           useDingbats=FALSE,
           compress = FALSE,
           dpi = 300)
    
    counter = counter + 1
  }}






# non-map viz -------------------------------------------------------------

df_adm2$District = factor(df_adm2$District, 
                          levels = c('Gasabo', 'Kicukiro','Nyarugenge', 'Burera','Gakenke','Gicumbi','Musanze','Rulindo','Bugesera', 'Gatsibo', 'Kayonza',  'Kirehe',   'Ngoma','Nyagatare','Rwamagana','Gisagara',    'Huye', 'Kamonyi', 'Muhanga','Nyamagabe',  'Nyanza','Nyaruguru', 'Ruhango',  'Karongi','Ngororero',  'Nyabihu','Nyamasheke',   'Rubavu',   'Rusizi',  'Rutsiro'))

x = df_adm2 %>% filter(project %like% 'CHAIN')

orderMech = x %>% 
  group_by(mechanism) %>% 
  summarise(num = n()) %>% 
  arrange(desc(num))

x$mechanism = factor(x$mechanism, levels = 
                       orderMech$mechanism)

ggplot(x, aes(x = District, y = mechanism)) +
  geom_point(size = 5, colour = 'dodgerblue')


# with basemap ------------------------------------------------------------

basemap = get_map(location = 'Kigali Rwanda', 
                  zoom = 9, source = 'google', maptype = 'terrain',
                  color = 'bw')

x = ggmap(basemap, darken = c(0.4,'black')) +
  # aes(x = long, y = lat)+
  # geom_polygon(aes(x = long, y = lat, group = group),
  # fill = grey30K, alpha = 0.3) +
  geom_polygon(aes(x = long, y = lat,
                   group = group,fill = id, alpha = 0.3), data = y) +
  geom_path(aes(x = long, y = lat,group = group),
            color="white", size = 0.1, data= y) +
  # coord_equal() +
  theme_blank() +
  geom_text(aes(x = long, y = lat, label = district), 
            data = rw.centroids,
            colour = grey90K,
            size = 0.7)

ggsave('~/Documents/USAID/Rwanda/CHAIN/plots/test.pdf',
       bg = 'transparent',
       paper = 'special',
       units = 'in',
       useDingbats=FALSE,
       compress = FALSE,
       dpi = 300)
