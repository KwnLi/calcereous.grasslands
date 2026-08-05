g <- as.numeric(commandArgs(trailingOnly = TRUE))
suppressMessages(library(tidyverse))
suppressMessages(library(terra))
suppressMessages(library(sf))
# suppressMessages(library(landscapemetrics))

datadir <- "/storage/home/kbl5733/gstorage/usda/Data/Calcereous/out"
outdir <- file.path(datadir, "countrylm")

country.files <- list.files(file.path(datadir, "countries"), pattern = "*.tif$")

country.g <- strsplit(country.files[g],"_")[[1]][1]

print(paste("Landscape metrics for", country.g))

calcgrass.nobuf <- terra::trim(terra::rast(file.path(datadir,"countries",country.files[g])))
# calcgrass.nobufn0 <- terra::ifel(calcgrass.nobuf == 0, NA, calcgrass.nobuf)

# calcgrass.buf <-terra::rast(file.path(datadir,"countries_buf",country.files[g]))
# calcgrass.bufn0 <- terra::ifel(calcgrass.buf == 0, NA, calcgrass.nobuf)

calcgrass.patches <- terra::patches(calcgrass.nobuf, directions=8, zeroAsNA=TRUE)

calcgrass.patchsizes <- terra::zonal(
  terra::cellSize(calcgrass.patches, unit = "ha"), calcgrass.patches,
  sum, as.raster = FALSE
  )

# nearest neighbor
calcgrass.patchpoly <- terra::as.polygons(calcgrass.patches, aggregate = TRUE, values = TRUE)
calcgrass.nearest <- terra::nearest(calcgrass.patchpoly, centroids = FALSE)

# output
outdf <- data.frame(country = country.g,
                    patch.max = max(calcgrass.patchsizes$area),
                    patch.min = min(calcgrass.patchsizes$area),
                    patch.mean = mean(calcgrass.patchsizes$area),
                    patch.med = median(calcgrass.patchsizes$area),
                    patch.sd = sd(calcgrass.patchsizes$area),
                    nn.max = max(calcgrass.nearest$distance),
                    nn.min = min(calcgrass.nearest$distance),
                    nn.mean = mean(calcgrass.nearest$distance),
                    nn.med = median(calcgrass.nearest$distance),
                    nn.sd = sd(calcgrass.nearest$distance))

# outdf[["areamn"]] <- landscapemetrics::lsm_c_area_mn(calcgrass.nobufn0)
# outdf[["areasd"]] <- landscapemetrics::lsm_c_area_sd(calcgrass.nobufn0)
# outdf[["ennmn"]] <- landscapemetrics::lsm_c_enn_mn(calcgrass.bufn0)
# outdf[["ennsd"]] <- landscapemetrics::lsm_c_enn_sd(calcgrass.bufn0)
# outdf[["areatot"]] <- landscapemetrics::lsm_c_ca(calcgrass.nobufn0)

# outdf <- dplyr::bind_rows(outdf)

write.csv(outdf, file.path(outdir, paste0(country.g, "_lm.csv")), row.names = FALSE)
