g <- as.numeric(commandArgs(trailingOnly = TRUE))
suppressMessages(library(tidyverse))
suppressMessages(library(terra))

indir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out/maskgrass/"
outdir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out/calcgrass"

grass.files <- list.files(indir, pattern = ".zip$")
grass.file.g <- grass.files[g]
tile.g <- gsub(".*(E\\d+N\\d+).*", "\\1", grass.file.g)

cat("Tile ID is: ", tile.g, "\n")

print(grass.file.g)

##### conduct the geoprocessing #####
grass.all <- terra::rast(grass.file.g)

# keep track of tiles
log_entry <- data.frame(tile = tile.g, error = NA)

tryCatch({
  calcgrass_only <- terra::ifel(grass.all==11111, 1, terra::ifel(grass.all <= 255, grass.all, 0))
  terra::NAflag(calcgrass_only) <- 255
  terra::writeRaster(calcgrass_only, file.path(outdir, paste0("calcgrass_",tile.g,".tif")))
  }, error = function(e) {
    log_entry$error <<- e$message
    }
  )

# --- per-tile log ---
logdir <- file.path(outdir, "tilelog")
dir.create(logdir, recursive = TRUE, showWarnings = FALSE)
write.csv(log_entry, file.path(logdir, paste0(tile.g, "_log.csv")), row.names = FALSE)
