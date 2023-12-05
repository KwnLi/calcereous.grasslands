library(tidyverse)
library(terra)

datadir <- "~/Documents/Calcereous/"

caco3 <- rast(paste0(datadir,"Layer/CaCo3.tif"))
litho <- rast(paste0(datadir,"Layer/Lit10.tif"))
# mow <- rast(paste0(datadir,"Layer/Mowing2017_2020.tif"))
rain <- rast(paste0(datadir,"Layer/Rain10.tif"))

grass.files <- list.files(
  paste0(datadir,"GRA_2018_010m_de_03035_v010/DATA"),
  pattern=".tif$")

# read in 10km grass tiles over germany
grass.list <- lapply(paste0(datadir,"GRA_2018_010m_de_03035_v010/DATA/",grass.files),
                     terra::rast)
grass.sprc <- sprc(grass.list)
grass.mos <- merge(grass.sprc, filename = paste0(datadir,"Layer/grass_mosaic.tif"))

# read in 10km impervious tiles over germany
imperv.files <- list.files(
  paste0(datadir,"IMD_2018_010m_de_03035_v020/DATA"),
  pattern=".tif$")

imperv.list <- lapply(paste0(datadir,"IMD_2018_010m_de_03035_v020/DATA/",imperv.files),
                     terra::rast)
imperv.sprc <- sprc(imperv.list)
imperv.mos <- merge(imperv.sprc, filename = paste0(datadir,"Layer/imperv_mosaic.tif"))

# read in mowing files
mow.list <- lapply(list.files(paste0(datadir,"Layer/mowing/"), 
                              pattern = "tif$", full.names = TRUE),
                     terra::rast)

# make everything consistent (project and mask)
rain.de <- rain %>% project(grass.mos)
grass.de <- grass.mos %>% mask(rain.de)
litho.de <- litho %>% project(grass.mos, method="near") %>% mask(rain.de)
mow.list.de <- lapply(mow.list, project, grass.mos, method="near")
caco3.de <- caco3 %>% project(grass.mos, method="near") %>% mask(rain.de)

# mowing: only keep 0-4
mow04.de <- ifel(mow.de >= 0 & mow.de <= 4, mow.de, NA)

grass01.de <- grass.de %>% subst(255, NA)  # replace 255 value (sea?) with NA

# write to file
projfolder <- "~/Documents/Calcereous/ProcessedData/Projected/"
writeRaster(rain.de, paste0(projfolder,"rain_de.tif"))
writeRaster(grass01.de, paste0(projfolder,"grass_de.tif"))
writeRaster(litho.de, paste0(projfolder,"litho_de.tif"))

writeRaster(caco3.de, paste0(projfolder,"caco3_de.tif"))
for(i in 1:4){
  writeRaster(mow.list.de[[i]], 
              paste0(projfolder,
                     "mowing_de",
                     list.files(paste0(datadir,"Layer/mowing/"), pattern = "tif$")[[i]] %>%
                       substr(17,21),
                     ".tif"))
}

# determine max value of mowing
mow.de.sds <- sds(mow.list.de)

mow.de.max <- app(mow.de.sds, max) # find max of the four layers (val 0-10)
mow.de.cats <- ifel(mow.de.max > 1, 99, mow.de.max)  # preserves 1 and 0 max mowing; rest is 99

writeRaster(mow.de.cats, paste0(projfolder,"mowonce_de.tif"))

##### Livestock #####
ctl <- rast(paste0(datadir,"Livestock/cattle/5_Ct_2015_Da.tif"))
shp <- rast(paste0(datadir,"Livestock/sheep/5_Sh_2015_Da.tif"))
got <- rast(paste0(datadir,"Livestock/goats/5_Gt_2015_Da.tif"))
hrs <- rast(paste0(datadir,"Livestock/horses/5_Ho_2015_Da.tif"))

writeRaster(ctl, paste0(outfolder,"cattle.tif"))
writeRaster(shp, paste0(outfolder,"sheep.tif"))
writeRaster(got, paste0(outfolder,"goats.tif"))
writeRaster(hrs, paste0(outfolder,"horses.tif"))

# livestock units
lu <- (0.5*ctl) + (0.5*hrs) + (0.125*shp) + (0.125*got)

lu.de <- lu %>% project(grass.mos, method="near") %>% mask(grass01.de)

lu.rcl <- matrix(c(0,0,25,60,
                   0,25,60,7000,
                   1,2,3,4),ncol = 3)

# convert units to per 1km (originally /10km) and reclassify
lucat.de <- (lu.de/100) %>% classify(rcl = lu.rcl, right=TRUE, include.lowest=TRUE)

writeRaster(lu.de, paste0(outfolder,"lu_de.tif"))

##### conduct the geoprocessing #####

grass.prec <- ifel(grass01.de == 1, 
                   ifel(rain.de >= 400,
                        ifel(rain.de <= 1000, 10, 20),
                        30),
                   grass01.de)
# Explanation
# If the pixel is grassland (=1), and if the annual precipitation is >= 400 and <= 1000, assign code “10”
# If the pixel is grassland (=1), and if the annual precipitation is >= 400 and > 1000, assign code “20”
# If the pixel is grassland (=1), and if the annual precipitation is < 400, assign code “30”
# If the pixel is not grassland (!=1), keep Grassland_orig value the same (results in 0 or ‘no data’ signifiers)

grass.caco3 <- ifel(grass01.de == 1,
                    ifel(caco3.de > 0, 
                         ifel(caco3.de <= 150, 100, 200), 
                         300),
                    grass01.de)
# If the pixel is grassland (=1), and if the CaCO3 is <= 150, assign code “100”
# If the pixel is grassland (=1), and if the CaCO3 is > 150, assign code “200”
# If the pixel is not grassland (!=1), keep Grassland_orig value the same (results in 0 or ‘no data’ signifiers)

grass.mow <- ifel(grass01.de == 1,
                    ifel(!is.na(mow.de.cats),
                         ifel(mow.de.cats > 0, 
                              ifel(mow.de.cats == 1, 2, 3), 
                              4),
                         grass01.de),
                  grass01.de)

# Explanation
# If the pixel is grassland (=1), and if the Mowing is = 1 per year assign code “2”
# If the pixel is grassland (=1), and if the Mowing is > 1 per year (for any year), assign code “3”
# If the pixel is grassland (=1), and if the Mowing is = 0, assign code “4”
# If the Pixel is grassland but no mowing information, assign 1
# If the pixel is not grassland (!=1), keep Grassland_orig value the same (results in 0 or ‘no data’ signifiers)

grass.litho <- ifel(grass01.de == 1,
                    ifel(litho.de == 101 | litho.de == 201,
                         1000, 2000),
                    grass01.de)

# Explanation
# If the pixel is grassland (=1), and if the lithology is either Carbonate or Mixed Sedimentary rocks, assign code “1000”
# If the pixel is grassland (=1), and if the lithology is not Carbonate/Mixed, assign code “2000”
# If the pixel is not grassland (!=1), keep Grassland_orig value the same (results in 0 or ‘no data’ signifiers)

grass.livestk <- ifel(grass01.de == 1,
                      ifel(lucat.de > 1,
                           ifel(lucat.de ==2, 2, 3),
                           1),
                      grass01.de)

# Explanation
# If the pixel is grassland (=1), and if livestock density is 0 LU per km2 (category 1), assign code "1"
# If the pixel is grassland (=1), and if livestock density is 0-25 LU per km2 (cat. 2), assign code "2"
# If the pixel is grassland (=1), and if livestock density is >25 per km2 (cat. 3+), assign code "3"

# combine layers

grass.calc <- grass.prec + grass.caco3 + grass.mow + grass.litho
grass.calc.lu <- grass.prec + grass.caco3 + grass.livestk + grass.litho

# remove zero
grass.calc2 <- subst(grass.calc, 0, NA)
grass.calc.lu2 <- subst(grass.calc.lu, 0, NA)

# remove imperv
imperv.0mask <- ifel(imperv.mos == 0, 1, 0)

grass.calc.noimperv <- grass.calc2 * imperv.0mask
grass.calc.lu.noimperv <- grass.calc.lu2 * imperv.0mask

# write out 
outfolder <- "~/Documents/Calcereous/ProcessedData/Output/"

writeRaster(grass.prec, paste0(outfolder,"grass_prec.tif"))
writeRaster(grass.caco3, paste0(outfolder,"grass_CaCO3.tif"))
writeRaster(grass.mow, paste0(outfolder,"grass_mow.tif"))
writeRaster(grass.litho, paste0(outfolder,"grass_litho.tif"))
writeRaster(grass.livestk, paste0(outfolder,"grass_livestk.tif"))

writeRaster(grass.calc2, paste0(outfolder,"calc_grass.tif"), overwrite=T)
writeRaster(grass.calc.noimperv, paste0(outfolder,"calc_grass_noimperv.tif"), overwrite=T)
writeRaster(grass.calc.lu.noimperv, paste0(outfolder,"calc_grass_LU_noimperv.tif"), overwrite=T)
