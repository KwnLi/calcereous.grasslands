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
calcgrass.buf <-terra::rast(file.path(datadir,"countries_buf",country.files[g]))

outdf <- list()

outdf[[areamn]] <- landscapemetrics::lsm_c_area_mn(calcgrass.nobuf)
outdf[[areacv]] <- landscapemetrics::lsm_c_area_sd(calcgrass.nobuf)
outdf[[areacv]] <- landscapemetrics::lsm_c_area_cv(calcgrass.nobuf)
outdf[[areatot]] <- landscapemetrics::lsm_c_ca(calcgrass.nobuf)
outdf[[ennmn]] <- landscapemetrics::lsm_c_enn_mn(calcgrass.buf)
outdf[[enncv]] <- landscapemetrics::lsm_c_enn_sd(calcgrass.buf)
outdf[[enncv]] <- landscapemetrics::lsm_c_enn_cv(calcgrass.buf)

outdf <- dplyr::bind_rows(outdf)

write.csv(outdf, file.path(outdir, paste0(country.g, "_lm.csv")), row.names = FALSE)
