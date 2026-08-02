g <- as.numeric(commandArgs(trailingOnly = TRUE))
suppressMessages(library(tidyverse))
suppressMessages(library(terra))
suppressMessages(library(sf))

indir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out/countries"
outdir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out"

country.files <- list.files(indir, pattern = "*.tif$")

country.g <- strsplit(country.files[g],"_")[[1]][1]

print(paste("Landscape metrics for", country.g))

country_calcgrass <-terra::rast(file.path(indir,country.files[g]))

rast.g <- lapply(file.path(indir, files.g), terra::rast)
sprc.g <- sprc(rast.g)

countrymerge <- terra::merge(sprc.g)

fname <- paste0(country.g, "_calcgrass.tif")
countrymask <- terra::mask(countrymerge, country.g.buf, filename = file.path(outdir, fname))
