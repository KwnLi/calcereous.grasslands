g <- as.numeric(commandArgs(trailingOnly = TRUE))
library(tidyverse)
library(terra)

source("./R/combine_layers.R")

eu <- read.csv("countries.csv")
eu.g <- eu$a2[g]


datadir <- "/90daydata/geoecoservices/calcereous/"

grass.dir <- paste0(datadir,"outdata/grass/",eu.g)
imperv.dir <- paste0(datadir,"outdata/imperv/",eu.g)
prec.file <-  paste0(datadir,"outdata/meanPrecip.tif")
caco3.file <- paste0(datadir,"outdata/CaCO3.tif")
litho.file <- paste0(datadir,"outdata/calcRock_eu_dis.gpkg")
livstk.file <- paste0(datadir,"outdata/livestock_cats.tif")

grass.files <- list.files(
  grass.dir,
  pattern=".tif$")

imperv.files <- list.files(
  imperv.dir,
  pattern=".tif$")

##### conduct the geoprocessing #####
prec <- rast(prec.file)
caco3 <- rast(caco3.file)
litho <- vect(litho.file)
livstk <- rast(livstk.file)

dir.create(paste0(datadir, "outdata/final/layercombine/", eu.g))
dir.create(paste0(datadir, "outdata/final/calcgrass/", eu.g))

layercombine <- list()
calcgrass <- list()

for(i in 1:length(grass.files)){
  grass.i <- rast(paste0(grass.dir,grass.files[i]))
  imperv.i <- rast(paste0(imperv.dir,imperv.files[i]))

  ext.i <- ext(grass.i)

  prec.i <- prec %>% crop(ext.i+res(prec)[1]) %>%
    resample(grass.i, method = "near") %>% crop(grass.i)

  caco3.i <- caco3 %>% crop(ext.i+res(caco3)[1]) %>%
    resample(grass.i, method = "near") %>% crop(grass.i)

  litho.i <- terra::crop(x=litho,y=ext.i+res(grass.i)[1]) %>%
    rasterize(grass.i, method = "near", field="code") %>% crop(grass.i)

  livstk.i <- livstk %>% crop(ext.i+res(livstk)[1]) %>%
    resample(grass.i, method = "near") %>% crop(grass.i)

  layercombine[[i]] <- combine_layers(
    grass.lyr = grass.i,
    prec.lyr = prec.i,
    caco3.lyr = caco3.i,
    litho.lyr = litho.i,
    livstk.lyr = livstk.i,
    imperv.lyr = imperv.i
  )

  mapid.i <- gsub(pattern = "(.*010m_)(.*)(_v010.tif)",
                  replacement = "\\2",
                  x = grass.files[i])

  writeRaster(layercombine[[i]],
              filename=paste0(datadir, "outdata/final/layercombine/", eu.g,
                              "/lcombine_",mapid.i,".tif"))

  calcgrass[[i]] <- ifel(layercombine[[i]] == 1112, 1, NA,
                        filename = paste0(datadir,"outdata/final/calcgrass/", eu.g,
                                          "/calcgrass_",mapid.i,".tif"))
}

# combine layers and output

# merge
lcombine.sprc <- sprc(layercombine)
calcgrass.sprc <- sprc(calcgrass)

# mosaic
merge(lcombine.sprc, filename = paste0(datadir, "outdata/final/layercombine/countries/lcombine_",eu.g,".tif"))
merge(calcgrass.sprc, filename = paste0(datadir, "outdata/final/calcgrass/countries/calcgrass_",eu.g,".tif"))

