
library(terra)
library(tidyterra)
library(ggplot2)
library(geosphere)

rm(list = ls())

# =========================================================
# AJUSTES (movelos a gusto)
# =========================================================

# Leyenda: posición en el panel (0 = izquierda/abajo, 1 = derecha/arriba)
legend_x <- 0.75
legend_y <- 0.27

# Barra de escala
bar_km       <- 500     # largo total de la barra (km)
bar_x        <- 0.8    # posición horizontal del CENTRO de la barra (0-1)
bar_y        <- 0.03    # posición vertical de la barra (0-1)
bar_height   <- 0.006   # alto de la barra (fracción de la altura del mapa)
label_offset <- 0.012   # distancia de las etiquetas por debajo de la barra
label_size   <- 2.2     # tamaño del texto de la escala

# Márgenes del panel (fracción de la extensión del raster)
pad_left   <- 0.06
pad_right  <- 0.20
pad_bottom <- 0.03
pad_top    <- 0.025

# Archivo
file_jenks <- "D:/enm_cchilensis/output/chelsa_5vars/final_models_rasters/jenks_3classes.tif"
file_out   <- "D:/enm_cchilensis//output/map_jenks.png"


# =========================================================
# 1. Raster
# =========================================================

r_jenks <- rast(file_jenks)

r_jenks <- as.factor(r_jenks)

levels(r_jenks) <- data.frame(
  ID = c(1, 2, 3),
  class = c("Low", "Medium", "High")
)


# =========================================================
# 2. Extent del panel
# =========================================================

e <- ext(r_jenks)
w <- e[2] - e[1]
h <- e[4] - e[3]

x_min <- e[1] - w * pad_left
x_max <- e[2] + w * pad_right
y_min <- e[3] - h * pad_bottom
y_max <- e[4] + h * pad_top


# =========================================================
# 3. Barra de escala (a la latitud media del mapa)
# =========================================================

mean_lat <- mean(c(e[3], e[4]))

# Centro de la barra según tus ajustes
sx <- x_min + (x_max - x_min) * bar_x
sy <- y_min + (y_max - y_min) * bar_y

# Extremos de la barra: bar_km/2 hacia cada lado a la latitud media
half_m <- bar_km * 1000 / 2
x_left  <- destPoint(c(sx, mean_lat), b = 270, d = half_m)[1]
x_right <- destPoint(c(sx, mean_lat), b = 90,  d = half_m)[1]

bar_h   <- h * bar_height
label_y <- sy - h * label_offset


# =========================================================
# 4. Mapa
# =========================================================

p_jenks <- ggplot() +
  
  geom_spatraster(
    data = r_jenks,
    maxcell = 1e6
  ) +
  
  scale_fill_manual(
    values = c(
      "Low"    = "#FEE08B",
      "Medium" = "#FDAE61",
      "High"   = "#D53E4F"
    ),
    name = "Suitability classes",
    na.value = "transparent",
    na.translate = FALSE
  ) +
  
  coord_sf(
    xlim = c(x_min, x_max),
    ylim = c(y_min, y_max),
    expand = FALSE
  ) +
  
  # Barra: primera mitad (negra)
  annotate(
    "rect",
    xmin = x_left, xmax = sx,
    ymin = sy, ymax = sy + bar_h,
    fill = "black", colour = "black", linewidth = 0.3
  ) +
  
  # Barra: segunda mitad (blanca)
  annotate(
    "rect",
    xmin = sx, xmax = x_right,
    ymin = sy, ymax = sy + bar_h,
    fill = "white", colour = "black", linewidth = 0.3
  ) +
  
  # Etiquetas centradas bajo cada marca
  annotate(
    "text",
    x = c(x_left, sx, x_right),
    y = label_y,
    label = c("0", bar_km / 2, paste(bar_km, "km")),
    hjust = 0.5,
    size = label_size
  ) +
  
  labs(
    x = "Longitude",
    y = "Latitude"
  ) +
  
  theme_grey(base_size = 14) +
  
  theme(
    axis.title.x = element_text(margin = margin(t = 12)),
    axis.title.y = element_text(margin = margin(r = 12)),
    
    legend.position = "inside",
    legend.position.inside = c(legend_x, legend_y),
    legend.background = element_rect(fill = "white", colour = "grey80"),
    legend.title = element_text(face = "bold", size = 9),
    legend.text = element_text(size = 8),
    legend.key.height = unit(0.35, "cm"),
    legend.key.width = unit(0.40, "cm"),
    legend.spacing.y = unit(0.25, "cm"),
    legend.margin = margin(5, 7, 5, 7)
  )

p_jenks


# =========================================================
# 5. Exportar
# =========================================================

ggsave(
  file_out,
  p_jenks,
  width = 6,
  height = 7.5,
  dpi = 300
)