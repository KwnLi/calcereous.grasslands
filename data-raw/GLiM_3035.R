# Download zip file mannually from: https://www.dropbox.com/scl/fi/5v00i8op7a9brmn4qeg8b/LiMW_GIS-2015.gdb.zip

unzip("downloads/LiMW_GIS 2015.gdb.zip", exdir = "data-raw")

library(sf)
library(dplyr)

litho <- st_read("data-raw/LiMW_GIS 2015.gdb")
lithoproj <- litho |> mutate(calcbed = ifelse(xx %in% c("sm","sc"),1,0)) |>
  dplyr::group_by(calcbed) |> dplyr::summarize(.groups = "drop") |>
  st_transform(crs = 3035)

st_write(lithoproj, "data/calcbed_3035.gpkg")
