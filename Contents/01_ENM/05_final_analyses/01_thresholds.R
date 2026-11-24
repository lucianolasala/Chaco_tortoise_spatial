
# Final statistics


library(kuenm)


rm(list=ls(all=TRUE))

sp_name <- "C_chilensis"
fmod_dir <- "./Contents/01_ENM/04_model_building/final_models_with_proj"
format <- "asc"
project <- TRUE
stats <- c("mean", "sd")
rep <- TRUE
scenarios <- list.dirs("/Contents/01_ENM/04_model_building/G/set_1", 
                       full.names = FALSE, recursive = FALSE)
ext_type <- "E"
out_dir <- "./Contents/01_ENM/04_model_building/final_model_stats"

kuenm_modstats(sp.name = sp_name, fmod.dir = fmod_dir, format = format, project = project, 
               statistics = stats, replicated = rep, proj.scenarios = scenarios, 
               ext.type = ext_type, out.dir = out_dir)


# Modelo final continuo

library(terra)


chilensis_m <- terra::rast("./Contents/01_ENM/04_model_building/final_model_stats/Statistics_E/calibration_mean.tif")
chilensis_g <- terra::rast("./Contents/01_ENM/04_model_building/final_model_stats/Statistics_E/Current_mean.tif")
class(chilensis_g)

continuo <- terra::mosaic(chilensis_m, chilensis_g, fun="mean")
plot(continuo)

writeRaster(continuo, "./Contents/01_ENM/04_model_building/final_models_rasters/continuo.tif")


# Modelo final binario

library(stars)
library(stringr)
library(tidyverse)


selected <- read_csv("./Contents/01_ENM/04_model_building/best_models/selected_models.csv")
selected_grid <- expand_grid(mod = selected$Model, mn = 0:9)


paths <- str_c("./Contents/01_ENM/04_model_building/final_models_with_proj/", selected$Model, 
               "_E/maxentResults.csv")


# Maximum training sensitivity plus specificity Cloglog threshold ####

get.thresholds <- function(x){
  th <- read_csv(x) %>%
    pull("Maximum training sensitivity plus specificity Cloglog threshold")
  th <- th[1:10]
  return(th)
}

th <- map(paths, get.thresholds) %>%
  unlist() %>%
  mean()

mean1.th <- read_stars("./Contents/01_ENM/04_model_building/final_models_with_proj/M_0.1_F_lqp_set_1_E/C_chilensis_avg.asc") %>%
  set_names("z") %>%
  mutate(z = case_when( z >= th ~ 1,
                        z < th ~ 0)) %>%
  write_stars("./Contents/01_ENM/04_model_building/final_models_rasters/cal_area_mean_thresh_MSS.tif")

mean2.th <- read_stars("./Contents/01_ENM/04_model_building/final_models_with_proj/M_0.1_F_lqp_set_1_E/C_chilensis_Current_avg.asc") %>%
  set_names("z") %>%
  mutate(z = case_when( z >= th ~ 1,
                        z < th ~ 0)) %>%
  write_stars("./Contents/01_ENM/04_model_building/final_models_rasters/proj_area_mean_thresh_MSS.tif")

# 10 percentile training presence Cloglog threshold ####

get.thresholds <- function(x){
  th <- read_csv(x) %>%
    pull("10 percentile training presence Cloglog threshold")
  th <- th[1:10]
  return(th)
}

th <- map(paths, get.thresholds) %>%
  unlist() %>%
  mean()

mean1.th <- read_stars("./Contents/01_ENM/04_model_building/final_models_with_proj/M_0.1_F_lqp_set_1_E/C_chilensis_avg.asc") %>%
  set_names("z") %>%
  mutate(z = case_when( z >= th ~ 1,
                        z < th ~ 0)) %>%
  write_stars("./Contents/01_ENM/04_model_building/final_models_rasters/cal_area_mean_thresh_10perc.tif")

mean2.th <- read_stars("./Contents/01_ENM/04_model_building/final_models_with_proj/M_0.1_F_lqp_set_1_E/C_chilensis_Current_avg.asc") %>%
  set_names("z") %>%
  mutate(z = case_when( z >= th ~ 1,
                        z < th ~ 0)) %>%
  write_stars("./Contents/01_ENM/04_model_building/final_models_rasters/proj_area_mean_thresh_10perc.tif")


# Mosaico ####

rm(list=ls(all=TRUE))

chilensis_m <- terra::rast("./Contents/01_ENM/04_model_building/final_models_rasters/cal_area_mean_thresh_10perc.tif")
chilensis_g <- terra::rast("./Contents/01_ENM/04_model_building/final_models_rasters/proj_area_mean_thresh_10perc.tif")

mosaico <- terra::mosaic(chilensis_m, chilensis_g, fun="mean")
plot(mosaico)

writeRaster(mosaico, "./Contents/01_ENM/04_model_building/final_models_rasters/binario_thresh_10perc.tif", overwrite=TRUE)


# Threshold (Marlon Cobos) ####

# Th 5% ####

# occ es una matrix con longitud latitud
# cont es el raster del modelo final medio en el área de calibración
# threshold es el valor de 1 a 100 que indica que porcentaje de error es 
# aceptable para tu modelo


library(raster)


rm(list=ls(all=TRUE))

cont <- raster("./Contents/01_ENM/04_model_building/final_model_stats/Statistics_E/calibration_mean.tif")
occ <- read.csv("./Contents/01_ENM/02_occurrence_data/occ_joint.csv")
occ <- occ[, -1]

o_suit <- raster::extract(cont, occ)
o_suit_sort <- sort(o_suit)
head(o_suit_sort)
length(o_suit_sort)

length(occ[, 1])
length(occ[, 1])*5
length(occ[, 1])*5/100
(length(occ[, 1])*5/100)+1
ceiling(length(occ[, 1])*5/100)+1

th5 <- o_suit_sort[ceiling(length(occ[, 1]) * 5 / 100) + 1]

mean.th5.cal <- read_stars("./Contents/01_ENM/04_model_building/final_model_stats/Statistics_E/calibration_mean.tif") %>%
  set_names("z") %>%
  mutate(z = case_when( z >= th5 ~ 1,
                        z < th5 ~ 0)) %>%
  write_stars("./Contents/01_ENM/04_model_building/final_models_rasters/cal_area_mean_thresh_5%.tif")

mean.th5.proj <- read_stars("./Contents/01_ENM/04_model_building/final_model_stats/Statistics_E/Current_mean.tif") %>%
  set_names("z") %>%
  mutate(z = case_when( z >= th5 ~ 1,
                        z < th5 ~ 0)) %>%
  write_stars("./Contents/01_ENM/04_model_building/final_models_rasters/proj_area_mean_thresh_5%.tif")

# Mosaico 

rm(list=ls(all=TRUE))


cal <- raster("./Contents/01_ENM/04_model_building/final_models_rasters/cal_area_mean_thresh_5%.tif") 
proj <- raster("./Contents/01_ENM/04_model_building/final_models_rasters/proj_area_mean_thresh_5%.tif")

m <- mosaic(cal, proj, fun = "mean")
plot(m)

writeRaster(m, filename = "./Contents/01_ENM/04_model_building/final_models_rasters/binario_thresh_5%", 
            format = "ascii", overwrite = TRUE)


# Th 10% ####

rm(list=ls(all=TRUE))


cont <- raster("./Contents/01_ENM/04_model_building/final_model_stats/Statistics_E/calibration_mean.tif")
occ <- read.csv("./Contents/01_ENM/02_occurrence_data/occ_joint.csv")
occ <- occ[, -1]

o_suit <- raster::extract(cont, occ)
o_suit_sort <- sort(o_suit)
head(o_suit_sort)
length(o_suit_sort)

th10 <- o_suit_sort[ceiling(length(occ[, 1])*10/100)+1]

mean.th10.cal <- read_stars("./Contents/01_ENM/04_model_building/final_model_stats/Statistics_E/calibration_mean.tif") %>%
  set_names("z") %>%
  mutate(z = case_when( z >= th10 ~ 1,
                        z < th10 ~ 0)) %>%
  write_stars("./Contents/01_ENM/04_model_building/final_models_rasters/cal_area_mean_thresh_10%.tif")

mean.th10.proj <- read_stars("./Contents/01_ENM/04_model_building/final_model_stats/Statistics_E/Current_mean.tif") %>%
  set_names("z") %>%
  mutate(z = case_when( z >= th10 ~ 1,
                        z < th10 ~ 0)) %>%
  write_stars("./Contents/01_ENM/04_model_building/final_models_rasters/proj_area_mean_thresh_10%.tif")

# Mosaico

rm(list=ls(all=TRUE))

cal <- raster("./Contents/01_ENM/04_model_building/final_models_rasters/cal_area_mean_thresh_10%.tif") 
proj <- raster("./Contents/01_ENM/04_model_building/final_models_rasters/proj_area_mean_thresh_10%.tif")

m <- mosaic(cal, proj, fun = "mean")
plot(m)

writeRaster(m, filename = "./Contents/01_ENM/04_model_building/final_models_rasters/binario_thresh_10%.tif", format = "ascii", overwrite = TRUE)
