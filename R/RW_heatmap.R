
library(data.table)

filteredDF = df %>% 
  group_by(Province, District,  shortName, subIR_ID) %>% 
  summarise(num = n()) %>% 
  ungroup() %>% 
  group_by(Province) %>% 
  arrange(desc(num))



ggplot(filteredDF, aes(x = District, 
                       y = shortName, 
                       fill = num)) +
  geom_tile(colour = 'white') +
  scale_fill_gradientn(colours = brewer.pal(9, 'YlGnBu')[3:9]) +
  facet_wrap(~Province, scales = 'free_x')
