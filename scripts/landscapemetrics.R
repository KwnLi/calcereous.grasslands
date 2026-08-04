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

calcgrass.buf <-terra::rast(file.path(datadir,"countries_buf",country.files[g]))
calcgrass.bufn0 <- terra::ifel(calcgrass.buf == 0, NA, calcgrass.nobuf)

outdf <- list()

outdf[["areamn"]] <- landscapemetrics::lsm_c_area_mn(calcgrass.nobufn0)
outdf[["areasd"]] <- landscapemetrics::lsm_c_area_sd(calcgrass.nobufn0)
outdf[["ennmn"]] <- landscapemetrics::lsm_c_enn_mn(calcgrass.bufn0)
outdf[["ennsd"]] <- landscapemetrics::lsm_c_enn_sd(calcgrass.bufn0)
outdf[["areatot"]] <- landscapemetrics::lsm_c_ca(calcgrass.nobufn0)

outdf <- dplyr::bind_rows(outdf)

write.csv(outdf, file.path(outdir, paste0(country.g, "_lm.csv")), row.names = FALSE)
