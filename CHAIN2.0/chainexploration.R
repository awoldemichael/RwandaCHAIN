# Exploring data from the CHAIN database to determine how to analyse and visualize it.

# Thinking there are essentially 3 types of behaviors want to encourage:
# 1. coordination: working in the same place on the same intervention.
# 2. collaboration: working in the same place but on different (ideally related) activities
# 3. learning: working on the same activities (therefore knowledge to share)


# coordination ------------------------------------------------------------
# How many people are working in the same location on the same thing?



# import part of the data -------------------------------------------------
source('~/GitHub/RwandaCHAIN/CHAIN2.0/RWA_importCHAIN.R')

# learning ----------------------------------------------------------------

View(chain %>% group_by(partner, techoffice, intervention_name) %>% summarise(n = n()) %>% ungroup() %>% group_by(partner) %>% mutate(pct = n/sum(n)))
chain_wide = chain %>% 
  select(province, district, sector, partner, intervention_name, techoffice) %>%
  mutate(works_on = 1) %>% 
  spread(partner, works_on) %>% 
  mutate(AEE = coalesce(AEE, 0),
         Caritas = coalesce(Caritas, 0),
         GC = coalesce(GC, 0),
         CRS = coalesce(CRS, 0),
         FXB = coalesce(FXB, 0),
         Hplus = coalesce(Hplus, 0),
         HSPH = coalesce(HSPH, 0),
         SFH = coalesce(SFH, 0)) %>% 
  rowwise() %>% 
  mutate(total = sum(AEE, Caritas, GC, CRS, FXB, Hplus, HSPH, SFH)
  )

# id the rows that could be coordinated

coord = chain_wide %>% filter(total > 1)
