g <- as.numeric(commandArgs(trailingOnly = TRUE))
suppressMessages(library(tidyverse))
suppressMessages(library(terra))
suppressMessages(library(sf))
suppressMessages(library(landscapemetrics))

datadir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out"
outdir <- file.path(datadir, "countrylm")

country.files <- list.files(file.path(datadir, "countries"), pattern = "*.tif$")

country.g <- strsplit(country.files[g],"_")[[1]][1]

print(paste("Landscape metrics for", country.g))

calcgrass.nobuf <-terra::rast(file.path(datadir,"countries",country.files[g]))
calcgrass.nobufn0 <- terra::ifel(calcgrass.nobuf == 0, NA, calcgrass.nobuf)

cat("\n")
print("Check unbuffered landscape data:")
print(terra::ncell(calcgrass.nobufn0))
print(terra::minmax(calcgrass.nobufn0))     # look for an extreme min or max
print(terra::freq(calcgrass.nobufn0))       # full table of distinct values + counts

print("Check trim result:")
calcgrass.nobufn0 <- terra::trim(calcgrass.nobufn0)
print(terra::ncell(calcgrass.bufn0))
print(terra::minmax(calcgrass.bufn0))     # look for an extreme min or max
print(terra::freq(calcgrass.bufn0))       # full table of distinct values + counts
