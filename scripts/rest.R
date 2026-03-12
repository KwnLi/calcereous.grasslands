library(httr)
library(jsonlite)
library(clmsapi)



url <- parse_url("https://image.discomap.eea.europa.eu/arcgis/rest/services/GioLandPublic/HRL_Grassland_2018/ImageServer")

GET("https://image.discomap.eea.europa.eu/arcgis/rest/services/GioLandPublic/HRL_Grassland_2018/ImageServer")
