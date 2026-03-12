complete.filepath <- "/Users/kevinli/Documents/Data/Calcereous/countries/"

complete.files <- list.files(complete.filepath)

complete.countries <- gsub(".tif", "", gsub("calcgrass_", "", complete.files))

countries <- read.csv("countries.csv")

missing.countries <- countries[!(countries$a2 %in% complete.countries),]

write.csv(missing.countries, "missing_countries.csv", row.names = FALSE)
