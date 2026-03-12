library(hdar)
library(jsonlite)
# username <- "kwnli"
# password <-"ShimmerShimmer79#Doors!!@"
# client <- Client$new(username, password, save_credentials = TRUE)

client <- Client$new()

client$get_token()

client$show_terms()

client$terms_and_conditions(term_id = 'all')

all_datasets <- client$datasets()

# query_template <- client$generate_query_template("EO:EEA:DAT:HRL:GRA")

query_list <- list(
  dataset_id = "EO:EEA:DAT:HRL:GRA",
  productType = "Grassland Mowing Events",
  resolution = "10m",
  year = "2020"
)

query <- toJSON(query_list, auto_unbox = TRUE)

matches <- client$search(query)

matches_id <- sapply(matches$results, FUN = function(x) { x$id })

# download test
matches_1 <- matches
matches_1$results <- matches$results[1]
matches_1$download("downloads")

# unzip
list.files("downloads")
unzip(file.path("downloads",list.files("downloads")), exdir = "data-raw")

dw <- list.files("data-raw", pattern = ".tif$")

# stuff
library(terra)
test <- rast(file.path("data-raw",dw))
crs("EPSG:3035")
