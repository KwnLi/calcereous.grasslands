g <- as.numeric(commandArgs(trailingOnly = TRUE))
suppressMessages(library(tidyverse))
suppressMessages(library(terra))
suppressMessages(library(future))
suppressMessages(library(foreach))

source("./R/combine_layers.R")

eu <- read.csv("countries.csv")
eu.g <- eu$a2[g]
cat(eu.g)

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
output.df <- data.frame(grasstile = grass.files, within.ext = NA, error = NA)

# parallel processing
# ncores <- future::availableCores()
# plan("multisession", workers = ncores - 2)


for(i in seq_along(grass.files)){
  grass.i <- rast(paste0(grass.dir,grass.files[i]))
  imperv.i <- rast(paste0(imperv.dir,imperv.files[i]))

  ext.i <- ext(grass.i)

  if(terra::relate(ext.i, min.ext, relation = "within")[1,1]){

    outdata <- tryCatch(
      {
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
        list(within.ext = "yes")
      },
      error = function(e) list(error = e$message)
    )

    output.df[i,names(outdata)] <- outdata
  }else{
    output.df[i,"within.ext"] <- "no"
  }
}

# combine layers and output

# merge
lcombine.sprc <- sprc(layercombine[sapply(layercombine,\(x) !is.null(x))])
calcgrass.sprc <- sprc(calcgrass[sapply(calcgrass,\(x) !is.null(x))])

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

write.csv(output.df, file = paste0(logdir, eu.g, "_tiles.csv"), row.names = FALSE)
