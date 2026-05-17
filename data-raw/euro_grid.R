library(sf)
library(terra)
library(giscoR)   # eurostat data: https://ropengov.github.io/giscoR/reference/gisco_get_countries.html#source

datadir <- "/Users/kevinl/Documents/mac_sync_pcloud/Calcereous/ProcessedData/Europe"
prec.file <-  file.path(datadir,"meanPrecip.tif")
caco3.file <- file.path(datadir,"CaCO3.tif")
litho.file <- file.path(datadir,"calcRock_eu_dis.gpkg")
livstk.file <- file.path(datadir,"livestock_cats.tif")

prec.lyr <- rast(prec.file)
caco3 <- rast(caco3.file)
litho.lyr <- vect(litho.file)
livstk <- rast(livstk.file)

min.ext <- ext(prec) %>% terra::intersect(ext(caco3)) %>% terra::intersect(ext(litho)) %>%
  terra::intersect(ext(livstk))

euro_grid <- sf::st_read("data-raw/eea_v_3035_100_km_eea-ref-grid-europe_p_2011_v01_r00/Grid_ETRS89-LAEA_100K.shp")

eu <- gisco_get_countries(epsg = "3035", region = "EU")
eu_clip <- sf::st_crop(eu, min.ext)

eu_grid <- euro_grid[eu_clip,]

sf::st_write(eu, "data/eu.gpkg")
sf::st_write(eu_clip, "data/eu_clip.gpkg")
sf::st_write(eu_grid, "data/eu_grid.gpkg")

