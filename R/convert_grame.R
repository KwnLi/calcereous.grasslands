convert_grame <- function(grame.lyr){
  grass.lyr <- terra::ifel(grame.lyr <= 1,
                           1,   # mowed one or fewer times
                           terra::ifel(grame.lyr <= 4,
                                       2,   # mowed more than once
                                       grame.lyr - 250,   # not grassland, 3 = non-grassland or 5 = outside area
                                       datatype = "INT2U"),
                           datatype = "INT2U")
  grass.lyr
}
