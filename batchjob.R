g <- as.numeric(commandArgs(trailingOnly = TRUE))
suppressMessages(library(tidyverse))
suppressMessages(library(terra))

source("./R/combine_layers.R")

eu <- read.csv("countries.csv")
eu.g <- eu$a2[g]


datadir <- "/90daydata/geoecoservices/calcereous/"
# datadir <- "/Users/kevinli/Documents/Data/Calcereous/"

grass.dir <- paste0(datadir,"outdata/grass/",eu.g,"/")
imperv.dir <- paste0(datadir,"outdata/imperv/",eu.g,"/")
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

min.ext <- ext(prec) %>% intersect(ext(caco3)) %>% intersect(ext(litho)) %>%
  intersect(ext(livstk))

dir.create(paste0(datadir, "outdata/final/layercombine/", eu.g), recursive = TRUE)
dir.create(paste0(datadir, "outdata/final/calcgrass/", eu.g), recursive = TRUE)

layercombine <- list()
calcgrass <- list()

# keep track of tiles
missingtiles <- list()
missingtilesct <- 1
usedtiles <- list()
usedtilesct <- 1

for(i in 1:length(grass.files)){
  grass.i <- rast(paste0(grass.dir,grass.files[i]))
  imperv.i <- rast(paste0(imperv.dir,imperv.files[i]))

  ext.i <- ext(grass.i)

  if(terra::relate(ext.i, min.ext, relation = "within")[1,1]){

    prec.i <- prec %>% crop(ext.i+res(prec)[1]) %>%
      resample(grass.i, method = "near") %>% crop(grass.i)

    caco3.i <- caco3 %>% crop(ext.i+res(caco3)[1]) %>%
      resample(grass.i, method = "near") %>% crop(grass.i)

    litho.i <- terra::crop(x=litho,y=ext.i+res(grass.i)[1]) %>%
      rasterize(grass.i, field="code") %>% crop(grass.i)

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

    usedtiles[[usedtilesct]] <- data.frame(a2 = eu.g, grasstile = grass.files[i])
    usedtilesct <- usedtilesct + 1
  }else{
    missingtiles[[missingtilesct]] <- data.frame(a2 = eu.g, grasstile = grass.files[i])
    missintilesct <- missingtilesct + 1
  }
}

# combine layers and output

# merge
lcombine.sprc <- sprc(layercombine)
calcgrass.sprc <- sprc(calcgrass)

# mosaic
mosaicdir_layercombine <-  paste0(datadir, "outdata/final/layercombine/countries/")
if(!dir.exists(mosaicdir_layercombine)){dir.create(mosaicdir_layercombine, recursive = TRUE)}

mosaicdir_calcgrass <-  paste0(datadir, "outdata/final/calcgrass/countries/")
if(!dir.exists(mosaicdir_calcgrass)){dir.create(mosaicdir_calcgrass, recursive = TRUE)}

merge(lcombine.sprc, filename = paste0(mosaicdir_layercombine, "lcombine_",eu.g,".tif"))
merge(calcgrass.sprc, filename = paste0(mosaicdir_calcgrass, "calcgrass_",eu.g,".tif"))

# write out tile tracking
logdir <- paste0(datadir,"outdata/final/tilelog/")
if(!dir.exists(logdir)){dir.create(logdir, recursive = TRUE)}

saveRDS(list(used=bind_rows(usedtiles), missing=bind_rows(missingtiles)),
        file = paste0(logdir, eu.g, "_tiles.rds"))
