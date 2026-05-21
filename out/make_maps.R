library(tidyverse)
library(sf)
library(giscoR)

world <- gisco_get_countries(resolution = 60, epsg = 3035)
eu_ext <- readRDS("data/eu_clip_ext.rds")
eu_cg <- st_read("out/grassland_eu27.gpkg")
nuts2_cg <- st_read("out/grassland_nuts2.gpkg")

# make maps
## EU
eu_cg <- eu_cg |>
  mutate(
    categ = cut(calc_grass, c(0, 10, 100, 500, 1000, 5000, 10000, 20000, Inf),
                dig.lab = 5, include.lowest = TRUE)
  )

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

## NUTS2
nuts2_cg <- nuts2_cg |>
  mutate(
    cg_km2 = calc_grass,   # calcereous grassland km2
    categ = cut(cg_km2, c(0, 10, 50, 100, 500, 1000, 5000, Inf),
                dig.lab = 5, include.lowest = TRUE)
  )

# Adjust labels.
labs2 <- levels(nuts2_cg$categ)
labs2[1] <- "< 10"
labs2[7] <- "> 5000"
levels(nuts2_cg$categ) <- labs2

nuts2_cg_plot <- ggplot(nuts2_cg) +
  geom_sf(data = world, fill = "#e1e1e1", color = NA) +
  geom_sf(data = nuts2_cg, mapping = aes(fill = categ)) +
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
    subtitle = "NUTS-2 level",
    fill = "Calcereous grassland (sq. km)"
  )

ggsave("out/nuts2_cg.png", nuts2_cg_plot, height = 8, width = 7, units = "in", dpi = 300, bg = "white")

