#check tilelog
library(tidyverse)
tilelogfiles <- list.files("data-raw/big/tilelog", full.names = TRUE)
tilelogfiles <- list.files(getwd(), pattern = ".csv$", full.names = TRUE)
tilelogfiles <- list.files("/storage/group/hlc30/default/usda/Data/Calcereous/out/maskgrass/tilelog", pattern = ".csv$", full.names = TRUE)
tilelogfiles <- list.files("/storage/group/hlc30/default/usda/Data/Calcereous/out/extractmask/tilelog", pattern = ".csv$", full.names = TRUE)

tilelogs <- lapply(tilelogfiles, read.csv) |> bind_rows()
