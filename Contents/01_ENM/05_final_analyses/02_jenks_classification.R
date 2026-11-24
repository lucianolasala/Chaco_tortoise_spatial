
# =====================================================
# Clasificacion MaxEnt - Fisher-Jenks
# Sin muestreo: todos los pixeles validos
# Chelonoidis chilensis
# =====================================================

library(terra)
library(classInt)

rm(list=ls())

# 1. Configuracion
archivo <- "./Contents/01_ENM/04_model_building/Final_model_stats/Statistics_E/calibration_mean.tif"

# 2. Cargar raster continuo
r <- rast(archivo)

stopifnot(nlyr(r) == 1)

# IMPORTANTE:
# El raster debe estar recortado y enmascarado a M.

# 3. Extraer TODOS los valores validos
valores <- values(r, mat = FALSE)
valores <- valores[is.finite(valores)]

cat("Pixeles validos:", length(valores), "\n")
cat("Valores unicos:", length(unique(valores)), "\n")

dim(r)
ncell(r)

#-------------------------------------------------------------------------------
# Muestra aleatoria del 5%
#-------------------------------------------------------------------------------

set.seed(123)

n5 <- round(length(valores) * 0.05)

muestra5 <- sample(
  valores,
  size = n5,
  replace = FALSE)

# Fisher-Jenks 5%
tiempo5 <- system.time({
  jenks5 <- classIntervals(
    muestra5,
    n = 3,
    style = "fisher",
    largeN = Inf,
    warnLargeN = FALSE)
  
})

print(tiempo5)
print(jenks5$brks)


#-------------------------------------------------------------------------------
# Muestra aleatoria del 10%
#-------------------------------------------------------------------------------

set.seed(123)

n10 <- round(length(valores) * 0.10)

muestra10 <- sample(
  valores,
  size = n10,
  replace = FALSE)

cat("Pixeles validos:", length(valores), "\n")
cat("Pixeles muestreados:", length(muestra10), "\n")

# Fisher-Jenks 10%
tiempo10 <- system.time({
  
  jenks10 <- classIntervals(
    muestra10,
    n = 3,
    style = "fisher",
    largeN = Inf,
    warnLargeN = FALSE)
  
})

print(tiempo10)
print(jenks10$brks)

#-------------------------------------------------------------------------------
# Muestra aleatoria del 20%
#-------------------------------------------------------------------------------

set.seed(456)

n20 <- round(length(valores) * 0.20)

muestra20 <- sample(
  valores,
  size = n20,
  replace = FALSE)


# Fisher-Jenks 20%

tiempo20 <- system.time({
  jenks20 <- classIntervals(
    muestra20,
    n = 3,
    style = "fisher",
    largeN = Inf,
    warnLargeN = FALSE)
  
})

print(tiempo20)
print(jenks20$brks)


#-----------------------------------------------
# Clasificacion final usando 20% de los pixeles
#-----------------------------------------------

# Cortes del analisis del 20 %
c1 <- jenks20$brks[2]
c2 <- jenks20$brks[3]

# Matriz de reclasificacion
matriz <- matrix(
  c(
    -Inf, c1, 1,
    c1, c2, 2,
    c2, Inf, 3
  ),
  ncol = 3,
  byrow = TRUE
)

# Clasificar raster completo
r_clases <- classify(
  r,
  matriz,
  right = FALSE
)

# Etiquetar categorias
levels(r_clases) <- data.frame(
  value = 1:3,
  Idoneidad = c("Baja", "Media", "Alta")
)

# Visualizar
plot(r_clases)

# Superficie por categoria (km2)
superficies <- zonal(
  cellSize(r_clases, unit = "km"),
  r_clases,
  fun = "sum",
  na.rm = TRUE)

print(superficies)

# =====================================================
# ESTABILIDAD DE LA CLASIFICACION FISHER-JENKS
# Comparacion 5%, 10% y 20%
# =====================================================

# 1. Funcion para clasificar usando los cortes
clasificar_jenks <- function(r, cortes) {
  
  matriz <- matrix(
    c(
      -Inf, cortes[2], 1,
      cortes[2], cortes[3], 2,
      cortes[3], Inf, 3
    ),
    ncol = 3,
    byrow = TRUE
  )
  
  classify(r, matriz, right = FALSE)
}

# 2. Clasificar el raster completo con cada conjunto de cortes
r_5  <- clasificar_jenks(r, jenks5$brks)
r_10 <- clasificar_jenks(r, jenks10$brks)
r_20 <- clasificar_jenks(r, jenks20$brks)

# 3. Funcion para comparar dos clasificaciones
comparar_clases <- function(r1, r2) {
  
  cambios <- global(
    ifel(r1 != r2, 1, 0),
    "sum",
    na.rm = TRUE
  )[1, 1]
  
  validos <- global(
    !is.na(r1) & !is.na(r2),
    "sum",
    na.rm = TRUE
  )[1, 1]
  
  porcentaje <- 100 * cambios / validos
  
  return(c(
    Pixeles_cambiados = cambios,
    Porcentaje_cambio = porcentaje,
    Concordancia = 100 - porcentaje
  ))
}

# 4. Comparaciones
comparacion <- rbind(
  "5% vs 10%" = comparar_clases(r_5, r_10),
  "5% vs 20%" = comparar_clases(r_5, r_20),
  "10% vs 20%" = comparar_clases(r_10, r_20)
)

# 5. Resultados
print(round(comparacion, 5))

#-------------------------------------------------------------------------------
# Exportar raster final (20%)
#-------------------------------------------------------------------------------

writeRaster(
  r_clases,
  "./Contents/01_ENM/04_model_building/final_models_rasters/jenks_3classes.tif",
  overwrite = TRUE,
  datatype = "INT1U",
  gdal = c("COMPRESS=LZW"))
