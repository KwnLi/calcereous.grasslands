g <- as.numeric(commandArgs(trailingOnly = TRUE))
suppressMessages(library(tidyverse))
suppressMessages(library(terra))

classdir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out/classgrass"
grassdir <- "/storage/home/kbl5733/scratch/downloads"
tempdir <- "/storage/home/kbl5733/scratch/tmp/grass"
outdir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out/maskgrass"

if(!dir.exists(outdir)){
  dir.create(outdir)
}

class.files <- list.files(classdir, pattern = ".tif$")

class.file.g <- class.files[g]
tile.g <- gsub(".*(E\\d+N\\d+).*", "\\1", class.file.g)
grass.zip.g <- list.files(grassdir, pattern = paste0("_GRA_.*",tile.g,".*\\.zip$"))

cat("Tile ID is: ", tile.g, "\n")

if(length(grass.zip.g)>1){
  stop("Too many grass matches for", tile.g)
}

# temp tile dir
tempdir.g <- file.path(tempdir, tile.g)
dir.create(tempdir.g, showWarnings = FALSE)

unzip(file.path(grassdir, grass.zip.g), exdir = tempdir.g)
grass.g.files <- list.files(tempdir.g, full.names = TRUE)
grass.g.tiffile <- grass.g.files[grep("tif$", grass.g.files)[1]]

crast <- rast(paste0(classdir, "/", class.file.g))
grast <- rast(grass.g.tiffile)

# keep track of tiles
log_entry <- data.frame(tile = tile.g, error = NA)

fname <- file.path(outdir,paste0("maskclagrass_",tile.g,".tif"))

tryCatch({
  class_mask <- terra::ifel(grast==1, crast, grast, filename=fname)
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
