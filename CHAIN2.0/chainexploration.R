# Exploring data from the CHAIN database to determine how to analyse and visualize it.

# Thinking there are essentially 3 types of behaviors want to encourage:
# 1. coordination: working in the same place on the same intervention.
# 2. collaboration: working in the same place but on different (ideally related) activities
# 3. learning: working on the same activities (therefore knowledge to share)


# coordination ------------------------------------------------------------
# How many people are working in the same location on the same thing?


# learning ----------------------------------------------------------------

View(sectors %>% group_by(partner, techoffice, intervention) %>% summarise(n = n()) %>% ungroup() %>% group_by(partner) %>% mutate(pct = n/sum(n)))
