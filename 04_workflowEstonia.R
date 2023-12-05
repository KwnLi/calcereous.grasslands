library(tidyverse)
library(terra)

datadir <- "~/Documents/Calcereous/"

grass.dir <- "grass_Estonia/DATA/"
imperv.dir <- "imp_Estonia/DATA/"
prec.file <-  "ProcessedData/Europe/meanPrecip.tif"
caco3.file <- "ProcessedData/Europe/caco3.tif"
litho.file <- "ProcessedData/Europe/calcRock_eu_dis.gpkg"
livstk.file <- "ProcessedData/Europe/livestock_cats.tif"

grass.files <- list.files(
  paste0(datadir,grass.dir),
  pattern=".tif$")

imperv.files <- list.files(
  paste0(datadir,imperv.dir),
  pattern=".tif$")

##### geoprocessing function #####

combine_layers <- function(
    grass.lyr=NULL,
    prec.lyr=NULL,
    caco3.lyr=NULL,
    litho.lyr=NULL,
    livstk.lyr=NULL,
    imperv.lyr=NULL
){
  # Combine grass and precipitation:
  # If the pixel is grassland (==1), and if the annual precipitation is >= 400 and <= 1000, assign code “10”
  # If the pixel is grassland (==1), and if the annual precipitation is > 1000, assign code “20”
  # If the pixel is grassland (==1), and if the annual precipitation is < 400, assign code “30”
  # If the pixel is not grassland (!=1), keep Grassland_orig value the same (results in 0 or ‘no data’ signifiers)
  
  grass.prec <- ifel(grass.lyr == 1, 
                     ifel(prec.lyr >= 400,
                          ifel(prec.lyr <= 1000, 10, 20),
                          30),
                     grass.lyr)
  
  # Combine grass and CaCO3:
  # If the pixel is grassland (==1), and if the CaCO3 is <= 200, assign code “100”
  # If the pixel is grassland (==1), and if the CaCO3 is > 200, assign code “200”
  # If the pixel is grassland (==1), and if the CaCO3 is == 0, assign code "300"
  # If the pixel is not grassland (!=1), keep Grassland_orig value the same (results in 0 or ‘no data’ signifiers)
  
  grass.caco3 <- ifel(grass.lyr == 1,
                      ifel(caco3.lyr > 0, 
                           ifel(caco3.lyr <= 200, 100, 200), 
                           300),
                      grass.lyr)
  
  # Combine grass and bedrock:
  # If the pixel is grassland (==1), and if the lithology is either Carbonate or Mixed Sedimentary rocks, assign code “1000”
  # If the pixel is grassland (==1), and if the lithology is not Carbonate/Mixed, assign code “2000”
  # If the pixel is not grassland (!=1), keep Grassland_orig value the same (results in 0 or ‘no data’ signifiers)
  
  grass.litho <- ifel(grass.lyr == 1,
                      ifel(litho.lyr == 101 | litho.lyr == 201,
                           1000, 2000),
                      grass.lyr)
  
  # Combine grass and livestock units:
  # If the pixel is grassland (==1), and if livestock density is 0-25 LU per km2 (category 1), assign code "2"
  # If the pixel is grassland (=1), and if livestock density is >25 per km2 (category 4), assign code "3"
  
  grass.livestk <- ifel(grass.lyr == 1,
                        ifel(livstk.lyr > 1, 3, 2),
                        grass.lyr)
  
  # combine layers
  # THIS IS WHERE MISSING LAYERS COULD BE SAVED AND CALCULATED
  grass.calc <- grass.prec + grass.caco3 + grass.livestk + grass.litho
  
  # remove zero
  grass.calc2 <- subst(grass.calc, 0, NA)
  
  # remove imperv with a mask
  imperv.0mask <- ifel(imperv.lyr == 0, 1, 0)
  
  grass.calc.noimperv <- grass.calc2 * imperv.0mask
  
  # return output
  return(grass.calc.noimperv)
}

##### conduct the geoprocessing #####
prec <- rast(paste0(datadir,prec.file))
caco3 <- rast(paste0(datadir,caco3.file))
litho <- vect(paste0(datadir,litho.file))
livstk <- rast(paste0(datadir,livstk.file))

calcgrass <- list()

for(i in 1:length(grass.files)){
  grass.i <- rast(paste0(datadir,grass.dir,grass.files[i]))
  imperv.i <- rast(paste0(datadir,imperv.dir,imperv.files[i]))
  
  ext.i <- ext(grass.i)
  
  prec.i <- prec %>% crop(ext.i+res(prec)[1]) %>%
    resample(grass.i, method = "near") %>% crop(grass.i)
  
  caco3.i <- caco3 %>% crop(ext.i+res(caco3)[1]) %>%
    resample(grass.i, method = "near") %>% crop(grass.i)
  
  litho.i <- terra::crop(x=litho,y=ext.i+res(grass.i)[1]) %>%
    rasterize(grass.i, method = "near", field="code") %>% crop(grass.i)
  
  livstk.i <- livstk %>% crop(ext.i+res(livstk)[1]) %>%
    resample(grass.i, method = "near") %>% crop(grass.i)
  
  calcgrass[[i]] <- combine_layers(
    grass.lyr = grass.i,
    prec.lyr = prec.i,
    caco3.lyr = caco3.i,
    litho.lyr = litho.i,
    livstk.lyr = livstk.i,
    imperv.lyr = imperv.i
  )
}

# merge
grass.sprc <- sprc(calcgrass)
grass.mos <- merge(grass.sprc, filename = paste0(datadir,"Estonia_calcgrass.tif"))

calcgrass.mos <- ifel(grass.mos == 1112, 1, NA, filename = paste0(datadir,"Estonia_calcgrass_only.tif"))






# write out 
outfolder <- "~/Documents/Calcereous/ProcessedData/Output/"

