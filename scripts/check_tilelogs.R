#check tilelog
tilelogfiles <- list.files("data/big/tilelog", full.names = TRUE)

tilelogs <- lapply(tilelogfiles, read.csv) |> bind_rows()
