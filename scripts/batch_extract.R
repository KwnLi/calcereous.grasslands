g <- as.numeric(commandArgs(trailingOnly = TRUE))
suppressMessages(library(tidyverse))
suppressMessages(library(sf))
suppressMessages(library(terra))

grassdir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out/maskgrass"
outdir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out"

grass.files <- list.files(grassdir, pattern = ".tif$", full.names = TRUE)
grass.file.g <- grass.files[g]
tile.g <- gsub(".*(E\\d+N\\d+).*", "\\1", grass.file.g)

# EU grid cell code
CellCode.g = paste0("100km",tile.g)

cat("Tile ID is:", tile.g, "\n")

##### conduct the zonal stat #####
extractdir <- file.path(outdir, "extractmask")
if(!dir.exists(extractdir)) {dir.create(extractdir, recursive = TRUE, showWarnings = FALSE)}

fname <- file.path(extractdir, paste0("maskgrass_",tile.g,".csv"))

if(file.exists(fname)){
  cat("Output already exists for tile:", tile.g, "-- skipping\n")
  quit(save = "no")
}

eu_grid_nuts2 <- sf::st_read("/storage/home/kbl5733/work/github/calcereous.grasslands/data/eu_grid_nuts2.gpkg")

grass.g <- terra::rast(grass.file.g)
eu_grid.g <- eu_grid_nuts2 |> dplyr::filter(CellCode == CellCode.g) |> terra::vect()

# keep track of tiles
log_entry <- data.frame(tile = tile.g, error = NA, CellCode = CellCode.g)

tryCatch({
  tile.extract <- terra::extract(grass.g, eu_grid.g, fun="table", wide = TRUE)
  tile.extract$NUTS_ID <- eu_grid.g$NUTS_ID
  print(tile.extract)

  }, error = function(e) {
    log_entry$error <<- e$message
    }
  )

# --- write out ---
write.csv(tile.extract, fname, row.names = FALSE)

# --- per-tile log ---
logdir <- file.path(extractdir, "tilelog")
dir.create(logdir, recursive = TRUE, showWarnings = FALSE)
write.csv(log_entry, file.path(logdir, paste0(tile.g, "_log.csv")), row.names = FALSE)
