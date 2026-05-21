library(tidyverse)
eu_grid <- sf::st_read("data/eu_grid.gpkg") |>
  mutate(tile = gsub(".*(E\\d+N\\d+).*", "\\1", CellCode))
extractdir <- "data-raw/extract"
extracttilelogdir <- "data-raw/extract/tilelog"
eu_nuts2 <- st_read("data/eu_nuts2.gpkg") |> st_drop_geometry()

extractfiles <- list.files(extractdir, pattern = "csv$")
tilelogfiles <- list.files(extracttilelogdir, pattern = "csv$")

extractlist <- lapply(file.path(extractdir, extractfiles), read.csv) |>
  setNames(extractfiles)
tileloglist <- lapply(file.path(extracttilelogdir, tilelogfiles), read.csv) |>
  setNames(tilelogfiles)

tilelogdf <- dplyr::bind_rows(tileloglist, .id = "file")
extractdf <- dplyr::bind_rows(extractlist, .id = "file")

extract_nuts2 <- extractdf |> group_by(NUTS_ID) |>
  summarize(across(starts_with("count"), ~sum(.x, na.rm = TRUE)), .groups = "drop")

extract_eu <- extractdf |>
  left_join(eu_nuts2, by = "NUTS_ID") |>
  group_by(CNTR_CODE, NAME_ENGL) |>
  summarize(across(starts_with("count"), ~sum(.x, na.rm = TRUE)), .groups = "drop")

write.csv(extract_nuts2, "data/classgrass_nuts2.csv", row.names = FALSE)
write.csv(extract_eu, "data/classgrass_eu.csv", row.names = FALSE)

# Troubleshooting

# eu_grid_success <- eu_grid |> filter(CellCode %in% paste0("100km",tilelogdf$tile))
# eu_grid_successerror <- eu_grid |> filter(CellCode %in%
#                                             paste0("100km",tilelogdf |> filter(is.na(error)) |>
#                                                      pull(tile)))
#
# # check why things didn't work
# tile.worked <- tilelogdf |> filter(is.na(error)) |> pull(tile) |> first()
# tile.error <- tilelogdf |> filter(!is.na(error)) |> pull(tile) |> first()
# tile.failed <- eu_grid |> filter(!(tile %in% tilelogdf$tile)) |> pull(tile) # only one failed and it is probably fine to skip
#
# ggplot() + geom_sf(data = eu_grid) +
#   geom_sf(data = eu_grid |> filter(tile %in% tilelogdf$tile), fill = "lightblue") +
#   geom_sf(data = eu_grid |> filter(tile %in% eu_grid_success$tile), fill = "green") +
#   geom_sf(data = eu_grid |> filter(tile %in% eu_grid_successerror$tile), fill = "orange") +
#   geom_sf(data = eu_grid |> filter(!(tile %in% tilelogdf$tile)), fill = "red") +
#   geom_sf(data = eu_grid |> filter(tile == tile.worked), fill = "darkgreen") +
#   geom_sf(data = eu_grid |> filter(tile == tile.error), fill = "darkred")
#
# eu_grid_nuts2 <- sf::st_read("data/eu_grid_nuts2.gpkg")
#
# classgrass.worked <- rast("data/big/classgrass_E26N17.tif")
# classgrass.error <- rast("data/big/classgrass_E26N18.tif")
# classgrass.failed <- rast(paste0("data/big/classgrass_", tile.failed,".tif"))
#
# extract.worked <- terra::extract(classgrass.worked,
#                                  eu_grid_nuts2 |>
#                                    dplyr::filter(CellCode == paste0("100km","E26N17")) |>
#                                    terra::vect(),
#                                  fun=table)
#
# extract.error <- terra::extract(classgrass.error,
#                                  eu_grid_nuts2 |>
#                                    dplyr::filter(CellCode == paste0("100km","E26N18")) |>
#                                    terra::vect(),
#                                  fun=table)
#
# extract.failed <- terra::extract(classgrass.failed,
#                                 eu_grid_nuts2 |>
#                                   dplyr::filter(CellCode == paste0("100km",tile.failed)) |>
#                                   terra::vect(),
#                                 fun=table)
