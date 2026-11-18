
# Recortar variables a M y G ####


library(terra)


# Directorios ####

# Carpeta con los raster originales
dir_in <- "./datos/chelsa_vars/bioclimaticas"

# Área M
M <- vect("./datos/Vectores/Ecoregions_chilensis_diss.shp")

# Área G
G <- vect("./datos/Vectores/Ecoregions_wo_chilensis_diss.shp")

# Salidas
dir_M <- "./datos/M"

dir_G <- "./datos/G"

dir.create(dir_M,
           recursive = TRUE,
           showWarnings = FALSE)

dir.create(dir_G,
           recursive = TRUE,
           showWarnings = FALSE)


# Lista de archivos ####

files <- list.files(
  dir_in,
  pattern="\\.tif$",
  full.names=TRUE
)

# Procesamiento M ####

for(i in seq_along(files)){
  
  cat("Procesando M:",
      basename(files[i]),
      "\n")
  
  r <- rast(files[i])
  
  r_M <- crop(r, M)
  r_M <- mask(r_M, M)
  
  writeRaster(
    r_M,
    filename = file.path(
      dir_M,
      basename(files[i])
    ),
    overwrite = TRUE
  )
}

# Procesamiento G ####

for(i in seq_along(files)){
  
  cat("Procesando G:",
      basename(files[i]),
      "\n")
  
  r <- rast(files[i])
  
  r_G <- crop(r, G)
  r_G <- mask(r_G, G)
  
  writeRaster(
    r_G,
    filename = file.path(
      dir_G,
      basename(files[i])
    ),
    overwrite = TRUE
  )
}
