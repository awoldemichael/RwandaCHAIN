# Import Mary's data on who is collaborating with whom based on integrated work plan.

library(readxl)
library(dplyr)
library(tidyr)

df_raw = read_excel('~/Documents/USAID/Rwanda/CHAIN/datain/WP w Kigali data.xlsx', sheet = 2)

df = df_raw %>% 
  bind_cols(data.frame(id = 1:nrow(df_raw))) %>% 
  select(-Province, -District, -Time) %>%  # Remove geographic/time info to get unique values
  distinct()


# make long version
df = df %>% gather(partner_num, ip, 3:9)

# Create combos of all the partners to stack data -------------------------
partners = c('Partner1', 'Partner2', 'Partner3', 'Partner4', 'Partner5', 'Partner6', 'Partner7')

# list of the pairwise combinations of the two columns
combos = combn(partners, 2)
combos = data.frame(t(combos))

# Sequential splaying of data long...



# collapse to nodes/edges -------------------------------------------------

df %>% group_by(ip) %>% summarise(n = n())
