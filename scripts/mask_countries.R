g <- as.numeric(commandArgs(trailingOnly = TRUE))
suppressMessages(library(tidyverse))
suppressMessages(library(terra))
suppressMessages(library(sf))

indir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out/calcgrass/"
outdir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out/countries"

grid.files <- list.files(indir, pattern = "*.tif$")

grideu <- sf::st_read("data/eu_grid.gpkg")
euclip <- sf::st_read("data/eu_clip.gpkg")

country.g <- euclip$NAME_ENGL[g]

print(paste("Clipping", country.g))

# country.g.buf <- sf::st_buffer(euclip[g,], 1000)   # buffer by 1km
country.g.buf <- euclip[g,]   # no buffer
grid.g <- grideu[country.g.buf,]  # intersecting buffers
tiles.g <-  gsub(".*(E\\d+N\\d+).*", "\\1", grid.g$CellCode)  # cell codes
calcgrass.g <- paste0("calcgrass_",tiles.g,".tif")
files.g <- grid.files[grid.files %in% calcgrass.g]   # grid files present in dir

print(paste(length(files.g), "/", length(calcgrass.g), "files found for", country.g))

rast.g <- lapply(file.path(indir, files.g), terra::rast)
sprc.g <- sprc(rast.g)

countrymerge <- terra::merge(sprc.g)

fname <- paste0(country.g, "_calcgrass.tif")
countrymask <- terra::mask(countrymerge, country.g.buf, filename = file.path(outdir, fname))
