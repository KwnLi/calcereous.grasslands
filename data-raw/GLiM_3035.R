# Download zip file mannually from: https://www.dropbox.com/scl/fi/5v00i8op7a9brmn4qeg8b/LiMW_GIS-2015.gdb.zip

unzip("downloads/LiMW_GIS 2015.gdb.zip", exdir = "data-raw")

library(terra)

litho <- vect("data-raw/LiMW_GIS 2015.gdb")
lithoproj <- project(litho, "epsg:3035")

writeVector(lithoproj, "data/GLiM_3035.gpkg")
