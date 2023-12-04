library(terra)
library(sf)
library(tidyverse)
library(rnaturalearth)
library(exactextractr)
library(ggeffects)
library(glmmTMB)
library(DHARMa)
library(sjPlot)

datadir <- "~/Documents/Calcereous/"
projfolder <- "~/Documents/Calcereous/ProcessedData/Projected/"
outfolder <- "~/Documents/Calcereous/ProcessedData/Output/"

mow <- rast(paste0(projfolder,"mowonce_de.tif"))
germany <- ne_countries(country="germany",scale = "large", returnclass = "sf")

lu.de.origproj <- rast(paste0(outfolder,"lu_de_origcrs.tif"))

germany_st <- ne_states(country="germany", returnclass = "sf") %>% 
  vect() %>% project(lu.de.origproj) %>%
  rasterize(lu.de.origproj, field = "diss_me")

lu.states <- rast(list(lu.de.origproj, germany_st))

lu.de.vect <- as.polygons(lu.states, dissolve = FALSE) %>% st_as_sf() %>% 
  st_transform(crs(mow))

# extract
sum_cats <- function(values, coverage_fractions){
  cats_sum <- data.frame(values, coverage_fractions) %>% group_by(values) %>%
    summarize(total_area = sum(coverage_fractions)) %>%
    pivot_wider(names_from = values, values_from = total_area)
  return(cats_sum)
}

mowareas <- exact_extract(mow, lu.de.vect, fun = sum_cats)

# lu + mow areas df
lu.mow <- lu.de.vect %>% bind_cols(mowareas) %>%
  rename(lu_perkm = `5_Ct_2015_Da`, mow0 = `0`, mow1 = `1`, mowmore = `99`, nograss = `NaN`) %>%
  mutate(mow1 = ifelse(is.na(mow1),0,mow1),
         mow0 = ifelse(is.na(mow0),0,mow0)) %>%
  mutate(totalgrass = mow1 + mow0 + mowmore) %>%
  mutate(prop_low_mow = mow1/totalgrass) %>%
  mutate(low_mow = round(mow1), totalgrass_rd = round(totalgrass)) %>%
  rownames_to_column(var = "cellID") %>% 
  left_join(ne_states(country="germany", returnclass = "sf") %>% 
              select(diss_me, name) %>% st_drop_geometry()) %>%
  mutate(livestock_class =
           case_when(
             lu_perkm == 0 ~ "lu1",
             lu_perkm > 0 & lu_perkm <= 25 ~ "lu2",
             lu_perkm > 25 ~ "lu3+"
           ))


ggplot(lu.mow, aes(lu_perkm, prop_low_mow, color = livestock_class)) + geom_point() + 
  xlab("Livestock units (/km2)") + ylab("Proportion of grassland mowed once") + 
  theme(legend.position = c(.75, .75))

ggplot(lu.mow, aes(log(lu_perkm), log(prop_low_mow))) + geom_smooth(method = "lm") + geom_point()


grass.glm <- glm(low_mow ~ lu_perkm, offset = log(totalgrass),
                 family = "poisson", data = lu.mow)
plot(ggeffect(grass.glm))

grass.glmm <- glmmTMB(low_mow ~ livestock_class + (1|name), offset = log(totalgrass_rd), 
                    family = "poisson", data = lu.mow)

grass.glmm.simresid <- simulateResiduals(grass.glmm)

lu.mow2 <- lu.mow %>% filter(!is.na(totalgrass_rd)) %>% st_drop_geometry()

grass.logreg <- glmmTMB(cbind(low_mow, totalgrass_rd - low_mow) ~ livestock_class + (1|name) + (1|cellID), 
                      family = "binomial", data = lu.mow2)
grass.logreg.simresid <- simulateResiduals(grass.logreg)

grass.logreg.effect <- ggeffect(grass.logreg)

ggplot(grass.logreg.effect$livestock_class) + 
  geom_pointrange(aes(x=x, y=predicted, ymin = conf.low, ymax = conf.high, color = x))  +
  theme(legend.position = "none") +
  xlab("Livestock class") + ylab("Predicted proportion of grassland mowed once")
