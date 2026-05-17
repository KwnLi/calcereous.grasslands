#' Combine component layers to make calcereous grassland output
#'
#' @param grass.lyr grassland layer
#' @param prec.lyr precip layer
#' @param caco3.lyr caco3 layer
#' @param litho.lyr lithography layer
#' @param livstk.lyr livestock layer
#' @param imperv.lyr impervious layer
#'
#' @return
#' @export
#'
combine_layers_grame <- function(
    grame.lyr=NULL,
    prec.lyr=NULL,
    caco3.lyr=NULL,
    litho.lyr=NULL,
    livstk.lyr=NULL,
    imperv.lyr
){
  # Convert mowing events to either one event or less (<=1) or greater than one mowing event (>1)
  # If the pixel is grassland mowed 1 or less times, assign code 1
  # If the pixel is grassland mowed more than 1 time, assign code 2
  # not grassland, 3 = non-grassland or 5 = outside area

  grass.lyr <- terra::ifel(grame.lyr <= 1,
                           1,   # mowed one or fewer times
                           terra::ifel(grame.lyr <= 4,
                                       2,   # mowed more than once
                                       grame.lyr - 250,   # not grassland, 3 = non-grassland or 5 = outside area
                                       datatype = "INT2U"),
                           datatype = "INT2U")

  # Combine grass and precipitation:
  # If the annual precipitation is >= 400 and <= 1000, assign code “10”
  # If the annual precipitation is > 1000, assign code “20”
  # If the annual precipitation is < 400, assign code “30”
  # If the annual precipitation is outside data area, assign code “90”

  grass.prec <- terra::ifel(is.na(prec.lyr),
                            90,
                            terra::ifel(prec.lyr >= 400,
                                        terra::ifel(prec.lyr <= 1000, 10, 20, datatype = "INT2U"),
                                        30, datatype = "INT2U"),
                            datatype = "INT2U")

  # Combine grass and CaCO3:
  # If the CaCO3 is <= 200, assign code “100”
  # If the CaCO3 is > 200, assign code “200”
  # If the CaCO3 is == 0, assign code "300"
  # If the CaCO3 is NA, assign code "900"

  grass.caco3 <- terra::ifel(is.na(caco3.lyr),
                             900,
                             terra::ifel(caco3.lyr > 0,
                                         terra::ifel(caco3.lyr <= 200, 100, 200, datatype = "INT2U"),
                                         300, datatype = "INT2U"),
                             datatype = "INT2U")

  # Combine grass and bedrock:
  # If lithology is either Carbonate or Mixed Sedimentary rocks, assign code “1000”
  # If lithology is not Carbonate/Mixed, assign code “2000”
  # If lithology is NA, assign code “9000”

  grass.litho <- terra::ifel(is.na(litho.lyr),
                             9000,
                             terra::ifel(litho.lyr == 101 | litho.lyr == 201,
                                         1000, 2000, datatype = "INT2U"),
                             datatype = "INT2U")

  # Combine grass and livestock units:
  # If livestock density is 0-25 LU per km2 (category 1), assign code "10000"
  # If livestock density is >25 per km2 (category 4), assign code "30000"
  # If livestock density is NA, assign code "90000"

  grass.livestk <- terra::ifel(is.na(livstk.lyr),
                               90000,
                               terra::ifel(livstk.lyr > 1, 30000, 10000, datatype = "INT2U"),
                               datatype = "INT2U")

  # remove outside area
  grass.lyr2 <- terra::subst(grass.lyr, 5, NA)

  # combine layers
  grass.calc <- grass.lyr2 + grass.prec + grass.caco3 + grass.litho + grass.livestk

  # return output
  return(grass.calc)
}
