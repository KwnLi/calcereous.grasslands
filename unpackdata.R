# library(DescTools)
# library(tidyverse)
# countrynames <- d.countries
#
# eu <- read.csv("countries.csv") %>%
#   left_join(countrynames, by = join_by(Country == name)) %>%
#   select(Country, a2) %>% mutate(a2 = tolower(a2))

datadir <- "/90daydata/geoecoservices/calcereous/"
# datadir <- "/Users/kevinli/Documents/Data/Calcereous/"

grasszip <- "/90daydata/geoecoservices/calcereous/grass/"
impervzip <- "/90daydata/geoecoservices/calcereous/imperv/"
# grasszip <- "/Users/kevinli/Documents/Data/Calcereous/EEA_grass/"
# impervzip <- "/Users/kevinli/Documents/Data/Calcereous/EEA_imperv/"

eu <- read.csv("countries.csv")

sel <- eu$a2

for(i in 1:length(sel)){
  grass.folder.i <- paste0(datadir,"outdata/grass/",sel[i])
  dir.create(grass.folder.i, recursive = TRUE)
  system(paste0("unzip -j ", grasszip,"*_", sel[i], "_* '*.tif' -d ", grass.folder.i))

  imperv.folder.i <- paste0(datadir,"outdata/imperv/",sel[i])
  dir.create(imperv.folder.i, recursive = TRUE)
  system(paste0("unzip -j ", impervzip, "*_", sel[i], "_* '*.tif' -d ", imperv.folder.i))
}
