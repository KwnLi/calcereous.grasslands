library(tidyverse)
eu_grid <- sf::st_read("data/eu_grid.gpkg") |>
  mutate(tile = gsub(".*(E\\d+N\\d+).*", "\\1", CellCode))
extractdir <- "data/big/extract"
extracttilelogdir <- "data/big/extract/tilelog"

extractfiles <- list.files(extractdir, pattern = "csv$")
tilelogfiles <- list.files(extracttilelogdir, pattern = "csv$")

extractlist <- lapply(file.path(extractdir, extractfiles), read.csv) |>
  setNames(extractfiles)
tileloglist <- lapply(file.path(extracttilelogdir, tilelogfiles), read.csv) |>
  setNames(tilelogfiles)

tilelogdf <- dplyr::bind_rows(tileloglist, .id = "file")
extractdf <- dplyr::bind_rows(extractlist, .id = "file") |>
  mutate(tile = gsub(".*(E\\d+N\\d+).*", "\\1", file)) |>
  left_join(tilelogdf, by = "tile")

eu_grid_success <- eu_grid |> filter(CellCode %in% paste0("100km",tilelogdf$tile))
eu_grid_successerror <- eu_grid |> filter(CellCode %in%
                                            paste0("100km",tilelogdf |> filter(is.na(error)) |>
                                                     pull(tile)))

# check why things didn't work
tile.worked <- tilelogdf |> filter(is.na(error)) |> pull(tile) |> first()
tile.error <- tilelogdf |> filter(!is.na(error)) |> pull(tile) |> first()
tile.failed <- eu_grid |> filter(!(tile %in% tilelogdf$tile)) |> pull(tile) # only one failed and it is probably fine to skip

ggplot() + geom_sf(data = eu_grid) +
  geom_sf(data = eu_grid |> filter(tile %in% tilelogdf$tile), fill = "lightblue") +
  geom_sf(data = eu_grid |> filter(tile %in% eu_grid_success$tile), fill = "green") +
  geom_sf(data = eu_grid |> filter(tile %in% eu_grid_successerror$tile), fill = "orange") +
  geom_sf(data = eu_grid |> filter(!(tile %in% tilelogdf$tile)), fill = "red") +
  geom_sf(data = eu_grid |> filter(tile == tile.worked), fill = "darkgreen") +
  geom_sf(data = eu_grid |> filter(tile == tile.error), fill = "darkred")

eu_grid_nuts2 <- sf::st_read("data/eu_grid_nuts2.gpkg")

classgrass.worked <- rast("data/big/classgrass_E26N17.tif")
classgrass.error <- rast("data/big/classgrass_E26N18.tif")
classgrass.failed <- rast(paste0("data/big/classgrass_", tile.failed,".tif"))

extract.worked <- terra::extract(classgrass.worked,
                                 eu_grid_nuts2 |>
                                   dplyr::filter(CellCode == paste0("100km","E26N17")) |>
                                   terra::vect(),
                                 fun=table)

extract.error <- terra::extract(classgrass.error,
                                 eu_grid_nuts2 |>
                                   dplyr::filter(CellCode == paste0("100km","E26N18")) |>
                                   terra::vect(),
                                 fun=table)

extract.failed <- terra::extract(classgrass.failed,
                                eu_grid_nuts2 |>
                                  dplyr::filter(CellCode == paste0("100km",tile.failed)) |>
                                  terra::vect(),
                                fun=table)
