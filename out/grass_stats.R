library(tidyverse)

eu <- read.csv("out/eu_tab.csv")

eu_sum <- eu %>% summarize(eu_totalarea = sum(total_area),
                           calcgrass_totalarea = sum(calcgrass, na.rm = TRUE),
                           calcgrass_intensive_totalarea = sum(calcgrass_intensive, na.rm = TRUE),
                           grass_missing_data_totalarea = sum(grass_missing_data),
                           allgrass_totalarea = sum(all_grass),
                           .groups = "drop") %>%
  mutate(
    calcgrass_pc_eutotalarea = 100*calcgrass_totalarea/eu_totalarea,
    abiotic_calcgrass_pc_eutotalarea = 100*(calcgrass_totalarea + calcgrass_intensive_totalarea)/eu_totalarea,
    allgrass_pc_eutotalarea = 100*allgrass_totalarea/eu_totalarea,
    calcgrass_pc_grasstotalarea = 100*calcgrass_totalarea/allgrass_totalarea,
    abiotic_calcgrass_pc_grasstotalarea = 100*(calcgrass_totalarea + calcgrass_intensive_totalarea)/allgrass_totalarea,
    missinggrass_pc_grasstotalarea = 100*grass_missing_data_totalarea/allgrass_totalarea,
  )

# country_sum <- eu %>%
#   mutate(
#     calcgrass_pc_totalarea = 100*calc_grass/total_area,
#     allgrass_pc_totalarea = 100*all_grass/total_area,
#     calcgrass_pc_grasstotalarea = 100*calc_grass/all_grass,
#     missinggrass_pc_grasstotalarea = 100*grass_missing_data/all_grass,
#   )

write.csv(eu_sum, "out/eu_summary.csv", row.names = FALSE)
# write.csv(country_sum, "out/country_summary.csv", row.names = FALSE)
