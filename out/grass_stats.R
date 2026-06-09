library(tidyverse)

eu <- read.csv("out/eu_tab.csv")

eu_sum <- eu %>% summarize(eu_totalarea = sum(total_area),
                           calc_grass_totalarea = sum(calc_grass, na.rm = TRUE),
                           intensive_calc_grass_totalarea = sum(calc_grass_intensive, na.rm = TRUE),
                           grass_missing_data_totalarea = sum(grass_missing_data),
                           all_grass_totalarea = sum(all_grass),
                           .groups = "drop") %>%
  mutate(
    calcgrass_pc_eutotalarea = 100*calc_grass_totalarea/eu_totalarea,
    abiotic_calcgrass_pc_eutotalarea = 100*(calc_grass_totalarea + intensive_calc_grass_totalarea)/eu_totalarea,
    allgrass_pc_eutotalarea = 100*all_grass_totalarea/eu_totalarea,
    calcgrass_pc_grasstotalarea = 100*calc_grass_totalarea/all_grass_totalarea,
    missinggrass_pc_grasstotalarea = 100*grass_missing_data_totalarea/all_grass_totalarea,
  )

country_sum <- eu %>%
  mutate(
    calcgrass_pc_totalarea = 100*calc_grass/total_area,
    allgrass_pc_totalarea = 100*all_grass/total_area,
    calcgrass_pc_grasstotalarea = 100*calc_grass/all_grass,
    missinggrass_pc_grasstotalarea = 100*grass_missing_data/all_grass,
  )

write.csv(eu_sum, "out/eu_summary.csv", row.names = FALSE)
write.csv(country_sum, "out/country_summary.csv", row.names = FALSE)
