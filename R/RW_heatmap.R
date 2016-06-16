
library(data.table)

filteredDF = df %>% 
  filter(Province == 'Western') %>% 
  group_by(District,  shortName, subIR_ID) %>% 
  summarise(num = n()) %>% 
  ungroup() %>% 
  arrange((num))

filteredDF$District = factor(filteredDF$District, levels = filteredDF$District)
filteredDF$shortName = factor(filteredDF$shortName, levels = filteredDF$shortName)
filteredDF$subIR_ID = factor(filteredDF$subIR_ID, levels = filteredDF$subIR_ID)



ggplot(filteredDF, aes(x = subIR_ID, 
                       y = shortName, 
                       fill = num)) +
  geom_tile(colour = 'white') +
  scale_fill_gradientn(colours = brewer.pal(9, 'YlGnBu')[3:9]) +
  facet_wrap(~District, scales = 'free') +
  theme_bw()
