library(terra)
library(sf)
library(tidyverse)
library(rnaturalearth)

datadir <- "~/Documents/Calcereous/"
outfolder <- "~/Documents/Calcereous/ProcessedData/Output/Europe/"

# grassland
eu_grass <- rast(paste0(datadir, "/GRA_2018_010m_eu_03035_v010/DATA/GRA_2018_010m_eu_03035_V1_0.tif"))
eu_ext <- ext(eu_grass)
eu_ext[1] <- 2500000 # adjust to take out islands

eu_grass2 <- crop(eu_grass, eu_ext)

##### Livestock #####
ctl <- rast(paste0(datadir,"Livestock/cattle/5_Ct_2015_Da.tif"))
shp <- rast(paste0(datadir,"Livestock/sheep/5_Sh_2015_Da.tif"))
got <- rast(paste0(datadir,"Livestock/goats/5_Gt_2015_Da.tif"))
hrs <- rast(paste0(datadir,"Livestock/horses/5_Ho_2015_Da.tif"))

# livestock units
lu <- (0.5*ctl) + (0.5*hrs) + (0.125*shp) + (0.125*got)

eu_ext_proj <- eu_ext %>% project(from = crs(eu_grass), to = crs(lu))

# convert units to per 1km (originally /10km)
lu.eu <- (lu/100)  %>% crop(eu_ext_proj)

# germany only
germany <- ne_countries(country="germany",scale = "large", returnclass = "sf") %>%
  st_transform(crs(lu.eu)) %>% vect()

lu.de.origproj <- lu.eu %>% crop(germany, mask = TRUE, touches = FALSE)


# output Germany polygons to read into mowing analysis
writeRaster(lu.de.origproj, paste0(outfolder,"lu_de_origcrs.tif"))

# reclass table
lu.rcl <- matrix(c(0,0,25,60,0,25,60,7000,1,2,3,4),ncol = 3)

# and reclassify
lucat.eu <- lu.eu %>% classify(rcl = lu.rcl, right=TRUE, include.lowest=TRUE)

# project and write out
lucat.eu.prj <- project(lucat.eu, crs(eu_grass2), method = "near", 
                        filename=paste0(outfolder, "lu_eu.tif"))
