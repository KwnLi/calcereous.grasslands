#check tilelog
tilelogfiles <- list.files("data-raw/big/tilelog", full.names = TRUE)
tilelogfiles <- list.files(getwd(), pattern = ".csv$", full.names = TRUE)

tilelogs <- lapply(tilelogfiles, read.csv) |> bind_rows()
