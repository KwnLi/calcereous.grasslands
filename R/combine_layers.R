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
combine_layers <- function(
    grass.lyr=NULL,
    prec.lyr=NULL,
    caco3.lyr=NULL,
    litho.lyr=NULL,
    livstk.lyr=NULL,
    imperv.lyr=NULL
){
  # Combine grass and precipitation:
  # If the pixel is grassland (==1), and if the annual precipitation is >= 400 and <= 1000, assign code “10”
  # If the pixel is grassland (==1), and if the annual precipitation is > 1000, assign code “20”
  # If the pixel is grassland (==1), and if the annual precipitation is < 400, assign code “30”
  # If the pixel is not grassland (!=1), keep Grassland_orig value the same (results in 0 or ‘no data’ signifiers)

  grass.prec <- terra::ifel(grass.lyr == 1,
                            terra::ifel(prec.lyr >= 400,
                                        terra::ifel(prec.lyr <= 1000, 10, 20, datatype = "INT2U"),
                                        30, datatype = "INT2U"),
                            grass.lyr, datatype = "INT2U")

  # Combine grass and CaCO3:
  # If the pixel is grassland (==1), and if the CaCO3 is <= 200, assign code “100”
  # If the pixel is grassland (==1), and if the CaCO3 is > 200, assign code “200”
  # If the pixel is grassland (==1), and if the CaCO3 is == 0, assign code "300"
  # If the pixel is not grassland (!=1), keep Grassland_orig value the same (results in 0 or ‘no data’ signifiers)

  grass.caco3 <- terra::ifel(grass.lyr == 1,
                             terra::ifel(caco3.lyr > 0,
                                         terra::ifel(caco3.lyr <= 200, 100, 200, datatype = "INT2U"),
                                         300, datatype = "INT2U"),
                             grass.lyr, datatype = "INT2U")

  # Combine grass and bedrock:
  # If the pixel is grassland (==1), and if the lithology is either Carbonate or Mixed Sedimentary rocks, assign code “1000”
  # If the pixel is grassland (==1), and if the lithology is not Carbonate/Mixed, assign code “2000”
  # If the pixel is not grassland (!=1), keep Grassland_orig value the same (results in 0 or ‘no data’ signifiers)

  grass.litho <- terra::ifel(grass.lyr == 1,
                             terra::ifel(litho.lyr == 101 | litho.lyr == 201,
                                         1000, 2000, datatype = "INT2U"),
                             grass.lyr, datatype = "INT2U")

  # Combine grass and livestock units:
  # If the pixel is grassland (==1), and if livestock density is 0-25 LU per km2 (category 1), assign code "2"
  # If the pixel is grassland (=1), and if livestock density is >25 per km2 (category 4), assign code "3"

  grass.livestk <- terra::ifel(grass.lyr == 1,
                               terra::ifel(livstk.lyr > 1, 3, 2, datatype = "INT2U"),
                               grass.lyr, datatype = "INT2U")

  # combine layers
  # THIS IS WHERE MISSING LAYERS COULD BE SAVED AND CALCULATED
  grass.calc <- grass.prec + grass.caco3 + grass.livestk + grass.litho

  # remove zero
  grass.calc2 <- terra::subst(grass.calc, 0, NA)

  # remove imperv with a mask
  imperv.0mask <- terra::ifel(imperv.lyr == 0, 1, 0)

  grass.calc.noimperv <- grass.calc2 * imperv.0mask

  # return output
  return(grass.calc.noimperv)
}
