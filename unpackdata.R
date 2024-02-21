# library(DescTools)
# library(tidyverse)
# countrynames <- d.countries
#
# eu <- read.csv("countries.csv") %>%
#   left_join(countrynames, by = join_by(Country == name)) %>%
#   select(Country, a2) %>% mutate(a2 = tolower(a2))

datadir <- "/90daydata/geoecoservices/calcereous/"

eu <- read.csv("countries.csv")

sel <- eu$a2

for(i in 1:length(sel)){
  grass.folder.i <- paste0(datadir,"outdata/grass/",sel[i])
  dir.create(grass.folder.i)
  system(paste0("unzip ", "/90daydata/geoecoservices/calcereous/grass/*_", sel[i], "_* '*.tif -j' -d ", grass.folder.i))

  imperv.folder.i <- paste0(datadir,"outdata/imperv/",sel[i])
  dir.create(imperv.folder.i)
  system(paste0("unzip ", "/90daydata/geoecoservices/calcereous/imperv/*_", sel[i], "_* '*.tif -j' -d ", imperv.folder.i))
}
