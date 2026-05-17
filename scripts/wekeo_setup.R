library(hdar)
library(jsonlite)
# username <- "kwnli"
# password <-"ShimmerShimmer79#Doors!!@"
# client <- Client$new(username, password, save_credentials = TRUE)

client <- Client$new()

client$get_token()

client$show_terms()

client$terms_and_conditions(term_id = 'all')

# all_datasets <- client$datasets()

query_list <- list(
  dataset_id = "EO:EEA:DAT:HRL:GRA",
  productType = "Grassland Mowing Events",
  resolution = "10m",
  year = "2020"
)

query <- toJSON(query_list, auto_unbox = TRUE)

matches <- client$search(query)

matches_id <- sapply(matches$results, FUN = function(x) { x$id })

# load EU 27 grid ids
eu27 <- sf::st_read("data/eu_grid.gpkg")

eu27_grids <- gsub(".*(E\\d+N\\d+).*", "\\1", eu27$CellCode)

# form search string
eu27_pattern <- paste(eu27_grids, collapse = "|")

# find matching grid names
matches_eu27 <- grep(eu27_pattern, matches_id)

# download test
matches_1 <- matches
matches_1$results <- matches$results[matches_eu27]
matches_1$download("downloads")



# unzip
list.files("downloads")
unzip(file.path("downloads","CLMS_HRLVLCC_GRAME_S2020_R10m_E10N25_03035_V01_R00.zip"), exdir = "data-raw")

dw <- list.files("data-raw", pattern = ".tif$")

# stuff
library(terra)
test <- rast(file.path("data-raw",dw))
crs("EPSG:3035")
