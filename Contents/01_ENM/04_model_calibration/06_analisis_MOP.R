
# ANÁLISIS MOP

# Reducir las resolucion de las variables ####

# M

rm(list=ls(all=TRUE))

library(raster)


files_M <- list.files(path = "./output/chelsa_thined3/calibration_m/set_1", 
                      pattern = ".asc$", full.names = TRUE)

for(i in 1:length(files_M)) {
  r <- raster(files_M[i])
  x <- raster::aggregate(r, fact=5, fun=mean)
  writeRaster(x, filename = paste(getwd(), "/output/chelsa_thined3/calibration_m/set_1/", 
                                  basename(files_M[i]), sep = ''), format = "ascii",
              overwrite = TRUE)
}

# G

rm(list=ls(all=TRUE))

files_G <- list.files(path = "./output/chelsa_thined3/projection_g/set_1/Current", 
                      pattern = ".asc$", full.names = TRUE)

for(i in 1:length(files_G)) {
  r <- raster(files_G[i])
  x <- raster::aggregate(r, fact=5, fun=mean)
  writeRaster(x, filename = paste(getwd(), "/output/chelsa_thined3/projection_g/set_1/Current/", 
                                  basename(files_G[i]), sep = ''), format = "ascii",
              overwrite = TRUE)
}

# MOP ####

rm(list=ls(all=TRUE))

library(kuenm)


rasters_m <- list.files("./output/chelsa_thined3/calibration_m/set_1/", pattern = "\\.asc$",
                        full.names = TRUE)

mvars <- raster::stack(rasters_m)  # kuenm_mop no acepta objetos SpatRaster de terra

rasters_g <- list.files("./output/chelsa_thined3/projection_g/set_1/Current", pattern = "\\.asc$",
                        full.names = TRUE)


gvars <- raster::stack(rasters_g)

resultado_mop <- kuenm_mop(M.variables = mvars, G.stack = gvars, percent = 10, 
                           comp.each = 2000)

raster::plot(resultado_mop)

writeRaster(resultado_mop, "./output/chelsa_thined3/analisis_MOP.asc", format = "ascii", 
            overwrite = TRUE)
