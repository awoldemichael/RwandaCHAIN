# Import Mary's data on who is collaborating with whom based on integrated work plan.

library(igraph)
library(readxl)
library(dplyr)
library(tidyr)
library(llamar)
library(stringr)

# graphical params --------------------------------------------------------
ip_colour = '#A7c6ed'
ip_dark = '#002f6c'


# load data ---------------------------------------------------------------


df_raw = read_excel('~/Documents/USAID/Rwanda/CHAIN/datain/WP w Kigali data.xlsx', sheet = 2)

df = df_raw %>% 
  select(-Province, -District, -Time) %>%  # Remove geographic/time info to get unique values
  distinct()

df = df %>% 
  bind_cols(data.frame(id = 1:nrow(df)))

# df1 = df %>% select(-contains("Partner"), Partner1)
# df2 = df %>% select(id, Partner2)
# 
# subset = df %>% select(id, contains("Partner1"), Partner4)
# expand.grid(subset)


# make long version (not really used)
df_long = df %>% gather(partner_num, ip, 3:9) %>% 
  mutate(ip = ifelse(ip == 'CIAT', 'H+', ip))

# Create combos of all the partners to stack data -------------------------
partners = c('Partner1', 'Partner2', 'Partner3', 'Partner4', 'Partner5', 'Partner6', 'Partner7')

# list of the pairwise combinations of the two columns
combos = combn(partners, 2)
combos = data.frame(t(combos))

combos = combos %>% mutate(col1 = as.character(X1), col2 = as.character(X2))


df_base = df %>% select(-contains("Partner"))

df_tidy = NULL

# Sequential splaying of data long...
for (i in 1:nrow(combos)) {
  df_temp = df %>% select_('id', partner1 = combos$col1[i], partner2 = combos$col2[i])
  
  df_merged = full_join(df_base, df_temp, by = 'id')  
  
  df_tidy = bind_rows(df_tidy, df_merged)
}

# Replace synonyms.
df_tidy = df_tidy %>%   
  mutate(partner1 = ifelse(partner1 == 'CIAT', 'H+', partner1),
         partner2 = ifelse(partner2 == 'CIAT', 'H+', partner2))


# collapse to nodes/edges -------------------------------------------------

# remove any missing connections
df_tidy = df_tidy %>% filter(!is.na(partner1), !is.na(partner2))

# calculate the edges.  Note: this is the permutation (e.g. directional); we want combinatorial, so need to do some extra work.
edges = df_tidy %>% group_by(partner1, partner2) %>% summarise(n = n()) %>% arrange(desc(n))

# create a merged partner combo, sorted alphabetically
edges = edges %>%
  mutate(partners = ifelse(partner1 > partner2, paste0(partner2, '_', partner1), 
                           paste0(partner1, '_', partner2)))

# recollapse, and split partners back into partner1 and partner2
edges = edges %>% 
  group_by(partners) %>% 
  summarise(n = sum(n)) %>% 
  separate(partners, c('source', 'target'), sep = '_') 


# pull out the unique partners
nodes = data.frame(id = unique(c(edges$source, edges$target)))

# pull out the number of unique partners each IP has
edges_long = edges %>% gather(key = partner_num, value = partner, -n)
unique_cnnxns = edges_long %>% group_by(partner) %>% summarise(unique = n())
num_cnnxns = edges_long %>% group_by(partner) %>% summarise(total = sum(n))

nodes = full_join(nodes, unique_cnnxns, by = c('id' = 'partner'))
nodes = full_join(nodes, num_cnnxns, by = c('id' = 'partner'))
  
# igraph ------------------------------------------------------------------
# tutorial at http://kateto.net/network-visualization

ntwk = igraph::graph_from_data_frame(d = edges, vertices = nodes, directed = FALSE)
E(ntwk)$width = E(ntwk)$n # sets edge width equivalent to the number of collaborations
V(ntwk) # returns vertices


l = layout.fruchterman.reingold(ntwk)
l = layout_(ntwk, as_star())
l = layout_in_circle(ntwk)

# l = layout_with_gem(ntwk)
# l = layout_with_lgl(ntwk)
# l = layout_with_mds(ntwk)
# l = layout_with_graphopt(ntwk)
# l = layout_nicely(ntwk)
# l = layout_with_kk(ntwk)
# l = layout_randomly(ntwk)

l = layout_with_dh(ntwk)
l = layout_with_drl(ntwk, use.seed = T)


plot(ntwk, edge.arrow.size = 0, layout = l,
     edge.curved = 0.1, edge.color = grey30K,
     vertex.size = 25,
     vertex.label.font = 2, vertex.label.family = 'Lato Light',
     vertex.label.color = ip_dark, vertex.frame.color = ip_dark,
     vertex.color = ip_colour)

for (i in 1:5){
l = layout_with_fr(ntwk, weights = E(ntwk)$width, niter = 1e5)
plot(ntwk, edge.arrow.size = 0, layout = l,
     edge.curved = 0.1, edge.color = grey30K,
     vertex.size = 25,
     vertex.label.font = 2, vertex.label.family = 'Lato Light',
     vertex.label.color = ip_dark, vertex.frame.color = ip_dark,
     vertex.color = ip_colour)
}



# wacky colors ------------------------------------------------------------

net = ntwk
V(ntwk)$color = sort(c(
  # '#393b79',
                      '#5254a3',
                      '#6b6ecf',
                      '#9c9ede',
                      # '#637939',
                      '#8ca252',
                      '#b5cf6b',
                      '#cedb9c',
                      # '#8c6d31',
                      '#bd9e39',
                      '#e7ba52',
                      '#e7cb94',
                      # '#843c39',
                      '#ad494a',
                      '#d6616b',
                      '#e7969c',
                      # '#7b4173',
                      '#a55194',
                      '#ce6dbd',
                      '#de9ed6'))

V(ntwk)$color = c('#3182bd',
                       '#6baed6',
                       '#9ecae1',
                       '#c6dbef',
                       '#e6550d',
                       '#fd8d3c',
                       '#fdae6b',
                       '#fdd0a2',
                       '#31a354',
                       '#74c476',
                       '#a1d99b',
                       '#c7e9c0',
                       '#756bb1',
                       '#9e9ac8',
                       '#bcbddc')
                       # '#dadaeb')

V(ntwk)$color = c('#1f77b4',
                   '#aec7e8',
                   '#ff7f0e',
                   '#ffbb78',
                   '#2ca02c',
                   '#98df8a',
                   '#d62728',
                   '#ff9896',
                   '#9467bd',
                   # '#c5b0d5',
                   '#8c564b',
                   # '#c49c94',
                   '#e377c2',
                   # '#f7b6d2',
                   '#7f7f7f',
                   '#c7c7c7',
                   '#bcbd22',
                   # '#dbdb8d',
                   '#17becf')
                   # '#9edae5',)

edge.start = ends(ntwk, es = E(ntwk), names = FALSE)[,1]
edge.col = V(ntwk)$color[edge.start]

l = layout_with_lgl(ntwk, root = 'CRS', coolexp = 1)

V(ntwk)$size = V(ntwk)$unique * 3

plot(ntwk, edge.arrow.size = 0, layout = l,
     edge.curved = 0.1, edge.color = edge.color,
     # vertex.size = 25,
     vertex.label.font = 2, vertex.label.family = 'Lato Light',
     vertex.label.color = grey90K, vertex.frame.color = grey75K)


# export data -------------------------------------------------------------

write.csv(edges, '~/GitHub/RwandaCHAIN/CHAIN-ntwk/data/20170414_IP_edges.csv')
write.csv(nodes, '~/GitHub/RwandaCHAIN/CHAIN-ntwk/data/20170414_IP_nodes.csv')

