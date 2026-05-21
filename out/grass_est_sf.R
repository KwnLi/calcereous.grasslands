library(tidyverse)
library(sf)
library(giscoR)

cg_nuts2 <- read.csv("data/classgrass_nuts2.csv")
cg_eu <- read.csv("data/classgrass_eu.csv")
eu <- st_read("data/eu_clip.gpkg")
nuts2 <- st_read("data/eu_nuts2_clip.gpkg") |> filter(ISO3_CODE %in% eu$ISO3_CODE)

# make output tables and sf
eu_cg_sf <- eu |> left_join(cg_eu, by = "NAME_ENGL") |>
  rowwise() |>
  mutate(
    calc_grass = count.11111 / 10000,
    non_calc_grass = sum(c_across(!matches("11111") & !matches("9") & matches("[12]$")) / 10000, na.rm = TRUE),
    grass_missing_data = sum(c_across(matches("9") & matches("[12]$")) / 10000, na.rm = TRUE),
    all_grass = sum(c_across(matches("[12]$")) / 10000, na.rm = TRUE),
    # test_grass = sum(calc_grass + non_calc_grass + grass_missing_data) - all_grass,
    total_area = sum(c_across(matches("[123]$")) / 10000, na.rm = TRUE)
  ) |> ungroup() |>
  select(-starts_with("count"))

nuts2_cg_sf <- nuts2 |> left_join(cg_nuts2, by = "NUTS_ID") |>
  rowwise() |>
  mutate(
    calc_grass = count.11111 / 10000,
    non_calc_grass = sum(c_across(!matches("11111") & !matches("9") & matches("[12]$")) / 10000, na.rm = TRUE),
    grass_missing_data = sum(c_across(matches("9") & matches("[12]$")) / 10000, na.rm = TRUE),
    all_grass = sum(c_across(matches("[12]$")) / 10000, na.rm = TRUE),
    # test_grass = sum(calc_grass + non_calc_grass + grass_missing_data) - all_grass,
    total_area = sum(c_across(matches("[123]$")) / 10000, na.rm = TRUE)
  ) |> ungroup() |>
  select(-starts_with("count"))

sf::st_write(eu_cg_sf, "out/grassland_eu27.gpkg", append = FALSE)
sf::st_write(nuts2_cg_sf, "out/grassland_nuts2.gpkg", append = FALSE)

# summary tables
eu_cg_tab <- eu_cg_sf |> sf::st_drop_geometry() |>
  select(NAME_ENGL, ISO3_CODE, calc_grass, non_calc_grass, grass_missing_data, all_grass, total_area)
nuts2_cg_tab <- nuts2_cg_sf |> sf::st_drop_geometry() |>
  select(NUTS_ID, NAME_LATN, NAME_ENGL, ISO3_CODE, calc_grass, non_calc_grass, grass_missing_data, all_grass, total_area)

write.csv(eu_cg_tab, "out/eu_tab.csv", row.names = FALSE)
write.csv(nuts2_cg_tab, "out/nuts2_tab.csv", row.names = FALSE)
