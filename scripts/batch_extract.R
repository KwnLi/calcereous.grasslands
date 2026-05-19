g <- as.numeric(commandArgs(trailingOnly = TRUE))
suppressMessages(library(tidyverse))
suppressMessages(library(sf))
suppressMessages(library(terra))

grassdir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out/classgrass"
outdir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out"

eu_grid_nuts2 <- sf::st_read("/storage/home/kbl5733/work/github/calcereous.grasslands/data/eu_grid_nuts2.gpkg")

grass.files <- list.files(grassdir, pattern = ".tif$", full.names = TRUE)
grass.file.g <- grass.files[g]
tile.g <- gsub(".*(E\\d+N\\d+).*", "\\1", grass.file.g)

# EU grid cell code
CellCode.g = paste0("100km",tile.g)

cat("Tile ID is:", tile.g, "\n")

##### conduct the zonal stat #####
grass.g <- terra::rast(grass.file.g)
eu_grid.g <- eu_grid_nuts2 |> dplyr::filter(CellCode == CellCode.g) |> terra::vect()

# keep track of tiles
log_entry <- data.frame(tile = tile.g, error = NA, CellCode = CellCode.g)

tryCatch({
  tile.extract <- terra::extract(grass.g, eu_grid.g, fun=table, ID = FALSE)
  print(tile.extract)
  tile.extract$NUTS_ID <- eu_grid.g$NUTS_ID
  }, error = function(e) {
    log_entry$error <<- e$message
    }
  )

# --- write out ---
extractdir <- file.path(outdir, "extract")
dir.create(extractdir, recursive = TRUE, showWarnings = FALSE)
write.csv(tile.extract, file.path(extractdir, paste0("classgrass_",tile.g,".csv")), row.names = FALSE)

# --- per-tile log ---
logdir <- file.path(extractdir, "tilelog")
dir.create(logdir, recursive = TRUE, showWarnings = FALSE)
write.csv(log_entry, file.path(logdir, paste0(tile.g, "_log.csv")), row.names = FALSE)
