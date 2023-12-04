library(rnaturalearth)
library(tidyverse)
library(sf)
library(terra)
library(exactextractr)

calcgrass <- rast("~/Documents/Calcereous/ProcessedData/Output/calc_grass_LU_noimperv.tif")

germany <- ne_countries(country="germany",scale = "large", returnclass = "sf")

crs(germany)

germany_proj <- st_transform(germany, crs(calcgrass))

identical(crs(germany_proj), crs(calcgrass)) # check if TRUE

# extract
sum_cats <- function(values, coverage_fractions){
  cats_sum <- data.frame(values, coverage_fractions) %>% group_by(values) %>%
    summarize(total_area = sum(coverage_fractions)) %>%
    pivot_wider(names_from = values, values_from = total_area)
  return(cats_sum)
}

areas <- exact_extract(calcgrass, germany_proj, fun = sum_cats)
