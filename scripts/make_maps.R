library(tidyverse)
library(sf)
library(giscoR)

cg_nuts2 <- read.csv("data/classgrass_nuts2.csv")
cg_eu <- read.csv("data/classgrass_eu.csv")
eu <- st_read("data/eu_clip.gpkg")
nuts2 <- st_read("data/eu_nuts2_clip.gpkg") |> filter(ISO3_CODE %in% eu$ISO3_CODE)
world <- gisco_get_countries(resolution = 60, epsg = 3035)
eu_ext <- readRDS("data/eu_clip_ext.rds")

# make output table
eu_cg_sf <- eu |> left_join(cg_eu, by = "NAME_ENGL") |>
  rowwise() |>
  mutate(
    calc_grass = count.11111,
    non_calc_grass = sum(c_across(!matches("11111") & !matches("9") & matches("[12]$")), na.rm = TRUE),
    grass_missing_data = sum(c_across(matches("9") & matches("[12]$")), na.rm = TRUE),
    all_grass = sum(c_across(matches("[12]$")), na.rm = TRUE),
    # test_sum = sum(calc_grass, non_calc_grass, grass_missing_data) - all_grass
    total_area = sum(c_across(matches("[123]$")), na.rm = TRUE)
  ) |> ungroup() |>
  select(-starts_with("count"))

nuts2_cg_sf <- nuts2 |> left_join(cg_nuts2, by = "NUTS_ID") |>
  rowwise() |>
  mutate(
    calc_grass = count.11111,
    non_calc_grass = sum(c_across(!matches("11111") & !matches("9") & matches("[12]$")), na.rm = TRUE),
    grass_missing_data = sum(c_across(matches("9") & matches("[12]$")), na.rm = TRUE),
    all_grass = sum(c_across(matches("[12]$")), na.rm = TRUE),
    # test_sum = sum(calc_grass, non_calc_grass, grass_missing_data) - all_grass
    total_area = sum(c_across(matches("[123]$")), na.rm = TRUE)
  ) |> ungroup() |>
  select(-starts_with("count"))

sf::st_write(eu_cg_sf, "out/grassland_eu27.gpkg", append = FALSE)
sf::st_write(nuts2_cg_sf, "out/grassland_nuts2.gpkg", append = FALSE)

# make maps
eu_cg <- eu |> left_join(cg_eu, by = "NAME_ENGL") |>
  mutate(
    cg_km2 = count.11111 / 10000,   # calcereous grassland ha
    categ = cut(cg_km2, c(0, 10, 100, 500, 1000, 5000, 10000, 20000, Inf),
                dig.lab = 5, include.lowest = TRUE)
  ) |>
  select(-starts_with("count"))

# Adjust labels.
labs <- levels(eu_cg$categ)
labs[1] <- "< 10"
labs[8] <- "> 20000"
levels(eu_cg$categ) <- labs

eu_cg_plot <- ggplot(eu_cg) +
  geom_sf(data = world, fill = "#e1e1e1", color = NA) +
  geom_sf(data = eu_cg, mapping = aes(fill = categ)) +
  # Center on Europe with EPSG 3035.
  coord_sf(
    xlim = eu_ext[c(1,2)],
    ylim = eu_ext[c(3,4)]
  ) +
  # Configure legends and color.
  scale_fill_manual(
    values = hcl.colors(length(labs), "Geyser", rev = TRUE),
    # Label missing values.
    labels = function(x) {
      ifelse(is.na(x), "No Data", x)
    },
    na.value = "#e1e1e1"
  ) +
  guides(fill = guide_legend(nrow = 1)) +
  theme_void() +
  theme(
    text = element_text(colour = "grey0"),
    panel.background = element_rect(fill = "#97dbf2"),
    panel.border = element_rect(fill = NA, color = "grey10"),
    plot.title = element_text(hjust = 0.5, vjust = -1, size = 12),
    plot.subtitle = element_text(
      hjust = 0.5, vjust = -2, face = "bold",
      margin = margin(b = 10, t = 5), size = 12
    ),
    plot.caption = element_text(
      size = 8, hjust = 0, margin =
        margin(b = 4, t = 8)
    ),
    legend.text = element_text(size = 7, ),
    legend.title = element_text(size = 7),
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.text.position = "bottom",
    legend.title.position = "top",
    legend.key.height = rel(0.5),
    legend.key.width = unit(0.1, "npc")
  ) +
  # Add labels.
  labs(
    title = "Total estimated area of calcereous grassland (2020)",
    subtitle = "Country level",
    fill = "Calcereous grassland (sq. km)"
  )

ggsave("out/eu_cg.png", eu_cg_plot, height = 8, width = 7, units = "in", dpi = 300, bg = "white")

