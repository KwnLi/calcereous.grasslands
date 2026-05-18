g <- as.numeric(commandArgs(trailingOnly = TRUE))
suppressMessages(library(tidyverse))
suppressMessages(library(terra))
source("./R/combine_layers_grame.R")

gramedir <- "/storage/home/kbl5733/scratch/downloads"
datadir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/vardata"
tempdir <- "/storage/home/kbl5733/scratch/tmp/grame"
outdir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out"

grame.files <- list.files(gramdedir, pattern = ".zip$")
grame.file.g <- grame.files[g]
tile.g <- gsub(".*(E\\d+N\\d+).*", "\\1", grame.file.g)

# temp tile dir
tempdir.g <- file.path(tempdir,tile.g)

unzip(file.path(gramedir, grame.file.g), exdir = tempdir.g)

grame.file <- file.path(tempdir, gsub("zip$", "tif", grame.file.g))
prec.file <-  file.path(datadir,"meanPrecip_1991_2020.tif")
caco3.file <- file.path(datadir,"CaCO3.tif")
litho.file <- file.path(datadir,"calcRock_eu_dis.gpkg")
livstk.file <- file.path(datadir,"livestock_cats.tif")

##### conduct the geoprocessing #####
grame <- terra::rast(grame.file)
prec <- terra::rast(prec.file)
caco3 <- terra::rast(caco3.file)
litho <- terra::vect(litho.file)
livstk <- terra::rast(livstk.file)

# keep track of tiles
log_entry <- data.frame(tile = tile.g, error = NA)

ext.grame <- terra::ext(grame)

tryCatch({
  prec.g <- prec %>% crop(ext.grame+res(prec)[1]) %>%
    resample(grame, method = "near") %>% crop(grame)

  caco3.g <- caco3 %>% crop(ext.grame+res(caco3)[1]) %>%
    resample(grame, method = "near") %>% crop(grame)

  litho.g <- terra::crop(x=litho,y=ext.grame+res(grame)[1]) %>%
    rasterize(grame, field="code") %>% crop(grame)

  livstk.g <- livstk %>% crop(ext.grame+res(livstk)[1]) %>%
    resample(grame, method = "near") %>% crop(grame)

  combine_layers_grame(
    grame.lyr = grame,
    prec.lyr = prec.g,
    caco3.lyr = caco3.g,
    litho.lyr = litho.g,
    livstk.lyr = livstk.g,
    filename = file.path(outdir, paste0("classgrass_", tile.g, ".tif"))
  )
  }, error = function(e) {
    log_entry$error <<- e$message
    }
  )

# --- per-tile log ---
logdir <- file.path(outdir, "tilelog")
dir.create(logdir, recursive = TRUE, showWarnings = FALSE)
write.csv(log_entry, file.path(logdir, paste0(tile.g, "_log.csv")), row.names = FALSE)

# --- clean up scratch ---
unlink(tempdir.g, recursive = TRUE)
