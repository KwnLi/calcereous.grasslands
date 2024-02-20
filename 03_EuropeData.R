library(terra)
library(sf)
library(tidyverse)

datadir <- "~/Documents/Calcereous/"
outfolder <- "~/Documents/Calcereous/ProcessedData/Europe/"

# grassland
eu_grass <- rast(paste0(datadir, "/GRA_2018_010m_eu_03035_v010/DATA/GRA_2018_010m_eu_03035_V1_0.tif"))
eu_ext <- ext(eu_grass)
eu_ext[1] <- 2500000 # adjust to take out islands

# eu_grass2 <- crop(eu_grass, eu_ext)

##### Livestock #####
ctl <- rast(paste0(datadir,"Livestock/cattle/5_Ct_2015_Da.tif"))
shp <- rast(paste0(datadir,"Livestock/sheep/5_Sh_2015_Da.tif"))
got <- rast(paste0(datadir,"Livestock/goats/5_Gt_2015_Da.tif"))
hrs <- rast(paste0(datadir,"Livestock/horses/5_Ho_2015_Da.tif"))

# livestock units
lu <- (0.5*ctl) + (0.5*hrs) + (0.125*shp) + (0.125*got)

eu_ext_proj <- eu_ext %>% project(from = crs(eu_grass), to = crs(lu))

# convert units to per 1km (originally /10km)
lu.eu <- (lu/100)  %>% crop(eu_ext_proj) %>%
  project(crs(eu_grass), method = "near") %>%
  crop(eu_ext)

# # germany only
# germany <- ne_countries(country="germany",scale = "large", returnclass = "sf") %>%
#   st_transform(crs(lu.eu)) %>% vect()
#
# lu.de.origproj <- lu.eu %>% crop(germany, mask = TRUE, touches = FALSE)
#
#
# # output Germany polygons to read into mowing analysis
# writeRaster(lu.de.origproj, paste0(outfolder,"lu_de_origcrs.tif"))

# reclass table
# lu.rcl <- matrix(c(0,0,25,60,
#                    0,25,60,7000,
#                    1,2,3,4),ncol = 3)
lu.rcl2 <- matrix(c(0,0,25,60,
                   0,25,60,7000,
                   1,1,4,4),ncol = 3)

# and reclassify
lucat.eu <- lu.eu %>% classify(rcl = lu.rcl2, right=TRUE, include.lowest=TRUE)

# project and write out
# writeRaster(lucat.eu, paste0(outfolder,"livestock_cats.tif"))
# writeRaster(lu.eu, paste0(outfolder,"livestock_perkm.tif"))

# read back in
# lucat.eu <- rast(paste0(outfolder,"livestock_perkm.tif"))

##### Calcereous bedrock #####
# calcrock.sf <- st_read(paste0(datadir,"CalcRock/LiMW_GIS 2015.gdb.zip"))
#
# eu_calcrock.vct <- calcrock.sf %>%
#   mutate(code = recode(xx, sc = 101, sm = 201, .default = 999)) %>%
#   vect() %>% project(crs(eu_grass)) %>% crop(eu_ext)
#
# writeVector(eu_calcrock.vct, paste0(outfolder,"calcRock_eu.gpkg"))

calcrock.vct <- vect(paste0(outfolder,"calcRock_eu.gpkg"))
calcrock.dis <- aggregate(calcrock.vct, by = "code")

writeVector(calcrock.dis, "calcRock_eu_dis.gpkg")

# eu_blank <- rast(calcrock.dis, res=100)
#
# eu_calcrock <- rasterize(calcrock.dis, eu_blank, field ="code")

##### Calcium carbonate soil #####
caco3 <- rast(paste0(datadir,"Caco3/Caco3.tif"))

caco3_eu <- caco3 %>% project(crs(eu_grass), method="bilinear")

writeRaster(caco3_eu, paste0(outfolder, "CaCO3.tif"))

##### Precipitation #####
prec <- rast(paste0(datadir,"Normal_1961-1990_bioclim/MAP.asc"))
crs(prec) <- 'PROJCS["Europe_Albers_Equal_Area_Conic",GEOGCS["GCS_European_1950",DATUM["D_European_1950",SPHEROID["International_1924",6378388.0,297.0]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Albers"],PARAMETER["False_Easting",0.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",15.0],PARAMETER["Standard_Parallel_1",43.0],PARAMETER["Standard_Parallel_2",62.0],PARAMETER["Latitude_Of_Origin",30.0],UNIT["Meter",1.0]]'
prec_eu <- prec %>% project(crs(eu_grass), method="bilinear")

writeRaster(prec_eu, paste0(outfolder, "meanPrecip.tif"))
