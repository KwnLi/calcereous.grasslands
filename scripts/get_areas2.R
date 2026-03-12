library(terra)
library(dplyr)

# LU

calcgrass_LU <- rast("~/Documents/Calcereous/ProcessedData/Output/calc_grass_LU_noimperv.tif")

calc_cells_LU <- freq(calcgrass_LU)

calc_areas_LU <- calc_cells_LU %>% mutate(area_m2 = count*10*10)

write.csv(calc_areas_LU, "calc_areas_LU.csv", row.names = FALSE)

# mow

calcgrass_mow <- rast("~/Documents/Calcereous/ProcessedData/Output/calc_grass_noimperv.tif")

calc_cells_mow <- freq(calcgrass_mow)

calc_areas_mow <- calc_cells_mow %>% mutate(area_m2 = count*10*10)

write.csv(calc_areas_mow, "calc_areas_mow.csv", row.names = FALSE)
