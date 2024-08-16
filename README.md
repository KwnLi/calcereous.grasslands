# Calcereous grasslands in Europe
Mapping calcereous grasslands

## Data layers

### Grassland layer

Grassland 2018 (raster 10 m), Europe.

Provides at pan-European level in the spatial resolution of 10 m a basic land cover classification with two thematic classes (grassland / non-grassland) for the 2018 reference year.

https://doi.org/10.2909/60639d5b-9164-4135-ae93-fb4132bb6d83

### Livestock layer

From the Gridded Livestock of the World database (GLW v4).

Gilbert, Marius; Cinardi, Giuseppina; Da Re, Daniele; Wint, William G. R.; Wisser, Dominik; Robinson, Timothy P., 2022, "Global cattle distribution in 2015 (5 minutes of arc)", https://doi.org/10.7910/DVN/LHBICE, Harvard Dataverse, V1 

Gilbert, Marius; Cinardi, Giuseppina; Da Re, Daniele; Wint, William G. R.; Wisser, Dominik; Robinson, Timothy P., 2022, "Global goats distribution in 2015 (5 minutes of arc)", https://doi.org/10.7910/DVN/YYG6ET, Harvard Dataverse, V1 

Gilbert, Marius; Cinardi, Giuseppina; Da Re, Daniele; Wint, William G. R.; Wisser, Dominik; Robinson, Timothy P., 2022, "Global horses distribution in 2015 (5 minutes of arc)", https://doi.org/10.7910/DVN/JJGCTX, Harvard Dataverse, V1 

Gilbert, Marius; Cinardi, Giuseppina; Da Re, Daniele; Wint, William G. R.; Wisser, Dominik; Robinson, Timothy P., 2022, "Global sheep distribution in 2015 (5 minutes of arc)", https://doi.org/10.7910/DVN/VZOYHM, Harvard Dataverse, V1 

#### Livestock units calculation

```
ctl <- rast("5_Ct_2015_Da.tif")
shp <- rast("5_Sh_2015_Da.tif")
got <- rast("5_Gt_2015_Da.tif")
hrs <- rast("5_Ho_2015_Da.tif")

lu <- (0.5*ctl) + (0.5*hrs) + (0.125*shp) + (0.125*got)

# convert units to per 1km (originally /10km)
lu.eu <- (lu/100) 

```

### Calcereous bedrock layer

Hartmann J, Moosdorf N (2012) The new global lithological map database GLiM: A representation of rock properties at the Earth surface. Geochemistry, Geophysics, Geosystems 13:. https://doi.org/10.1029/2012GC004370

The high resolution data is available here:
https://www.geo.uni-hamburg.de/en/geologie/forschung/aquatische-geochemie/glim.html 

**Values (Integer data)**

101 = class “sc”, Carbonate Sedimentary Rocks

201 = class “sm”, Mixed Sedimentary Rocks

999 = all other classes


### Calcereous soil layer

Ballabio, C., Lugato, E., Fernández-Ugalde, O., Orgiazzi, A., Jones, A., Borrelli, P., Montanarella, L. and Panagos, P., 2019. Mapping LUCAS topsoil chemical properties at European scale using Gaussian process regression. Geoderma, 355: 113912.

### Precipitation layer

Marchi, M., Castellanos-Acuna, D., Hamann, A., Wang, T., Ray, D. Menzel, A. 2020. ClimateEU, scale-free climate normals, historical time series, and future projections for Europe. Scientific Data 7: 428. doi: 10.1038/s41597-020-00763-0

Using Mean Annual Precipitation (MAP) layer for 1961-1990 Normals

## Layer legend

|Code  |Explanation  |
|-----:|:------------|
|`1000` | lithology is either Carbonate or Mixed Sedimentary rocks|
|`2000` | lithology is not Carbonate/Mixed |
|`100`  | CaCO3 is > 0 and <= 200 |
|`200`  | CaCO3 is > 200 |
|`300`  | CaCO3 is == 0 |
|`10`   | Annual precipitation is >= 400 and <= 1000 |
|`20`   | Annual precipitation is > 1000 |
|`30`   | Annual precipitation is < 400 |
|`2`    | Livestock density is 0-25 LU per km2
|`3`    | Livestock density is >25 per km2

Calcereous grassland code is `1112`

## Impervious layer

Areas with impervious cover are masked out of the grassland dataset. Impervious data is based on:

European Environment Agency, “Impervious Built-up 2018 (raster 10 m), Europe, 3-yearly, Aug. 2020.” EEA geospatial data catalogue, Aug. 18, 2020. doi: https://doi.org/10.2909/3e412def-a4e6-4413-98bb-42b571afd15e.


## Limitations

Border areas differ between layers because of differences in resolution and mapping detail. This could be calculated but generally, grasslands near coastline may be missing because of omission of one or more layers.
