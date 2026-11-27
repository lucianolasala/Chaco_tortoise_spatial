
library(terra)

rm(list=ls())

carpeta <- "./Contents/03_Protected_areas/aapp_shapefiles"
archivos <- list.files(carpeta, pattern = "\\.shp$", full.names = TRUE)

leer <- function(f) {
  v <- vect(f)
  v <- project(v, "EPSG:4326")        
  v <- makeValid(v)
  v <- v[, "NAME"]                  
  v$origen <- tools::file_path_sans_ext(basename(f))  
  v
}

p <- vect(lapply(archivos, leer))     # une todo en una sola capa
p$area_km2 <- expanse(p, unit = "km")

write.csv(as.data.frame(p), "areas_poligonos.csv", row.names = FALSE)
writeVector(p, "aapp_unificado.gpkg", overwrite = TRUE)
