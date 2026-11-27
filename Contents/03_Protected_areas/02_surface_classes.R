
library(terra); library(sf); library(exactextractr); library(dplyr); library(tidyr); library(openxlsx)

rm(list=ls())

r <- rast("./Contents/01_ENM/04_model_building/final_models_rasters/jenks_3classes.tif") # clases 1 (low), 2 (medium), 3 (high)
p <- vect("./Contents/03_Protected_areas/aapp_unificado.gpkg")           

p <- project(p, crs(r))                     
p$id <- seq_len(nrow(p))                    

# Área real de cada celda (km2)
area_km2 <- cellSize(r, unit = "km")

# Una capa por clase: área de la celda si es de esa clase, 0 si no
capas <- rast(lapply(1:3, function(k) ifel(r == k, area_km2, 0)))
names(capas) <- c("c1", "c2", "c3")

# Área de cada clase dentro de cada polígono
ext <- exact_extract(capas, st_as_sf(p), fun = "sum")
names(ext) <- c("c1", "c2", "c3")

# Tabla ancha: una fila por polígono
res <- bind_cols(as.data.frame(p)[, c("NAME", "origen")], ext) |>
  mutate(km2_total = c1 + c2 + c3)

# Tabla larga: una fila por polígono y clase (solo donde hay área)
largo <- res |>
  pivot_longer(c1:c3, names_to = "clase", names_prefix = "c", values_to = "area_km2") |>
  mutate(clase = as.integer(clase),
         pct = area_km2 / km2_total * 100) |>
  filter(area_km2 > 0)

write.xlsx(list("Por polígono" = res, "Por clase" = largo),
           "./Contents/03_Protected_areas/aapp_area_por_clase.xlsx")
