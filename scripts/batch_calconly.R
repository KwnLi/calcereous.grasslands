g <- as.numeric(commandArgs(trailingOnly = TRUE))
suppressMessages(library(tidyverse))
suppressMessages(library(terra))

indir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out/maskgrass/"
outdir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out/calcgrass"

grass.files <- list.files(indir, pattern = ".tif$")
grass.file.g <- grass.files[g]
tile.g <- gsub(".*(E\\d+N\\d+).*", "\\1", grass.file.g)

cat("Tile ID is: ", tile.g, "\n")

print(grass.file.g)

##### conduct the geoprocessing #####
grass.all <- terra::rast(file.path(indir,grass.file.g))

# keep track of tiles
log_entry <- data.frame(tile = tile.g, error = NA)

tryCatch({
  calcgrass_only <- terra::ifel(grass.all==11111, 1, terra::ifel(grass.all <= 255, grass.all, 0))
  terra::NAflag(calcgrass_only) <- 255
  fname <- file.path(outdir, paste0("calcgrass_",tile.g,".tif"))
  print(fname)
  terra::writeRaster(calcgrass_only, filename = fname)
  }, error = function(e) {
    log_entry$error <<- e$message
    }
  )

# --- per-tile log ---
logdir <- file.path(outdir, "tilelog")
dir.create(logdir, recursive = TRUE, showWarnings = FALSE)
write.csv(log_entry, file.path(logdir, paste0(tile.g, "_log.csv")), row.names = FALSE)
