
library(terra)
library(tidyterra)
library(ggplot2)
library(sf)
library(patchwork)
library(geosphere)

rm(list = ls())

# ---------------------------------------------------------
# 1. Load rasters
# ---------------------------------------------------------

r_cont <- rast("./Contents/01_ENM/04_model_building/final_models_rasters/continuo.tif")
r_bin  <- rast("./Contents/01_ENM/04_model_building/final_models_rasters/binario_thresh_10perc.tif")

r_bin <- as.factor(r_bin)

levels(r_bin) <- data.frame(
  ID = c(0, 1),
  class = c("Absence", "Presence")
)


# ---------------------------------------------------------
# 2. Load administrative boundaries
# ---------------------------------------------------------

arg_adm1 <- st_read("./Contents/01_ENM/04_model_building/paises_adm/ARG_adm/ARG_adm1.shp", quiet = TRUE)
bol_adm1 <- st_read("./Contents/01_ENM/04_model_building/paises_adm/BOL_adm/BOL_adm1.shp", quiet = TRUE)
pry_adm1 <- st_read("./Contents/01_ENM/04_model_building/paises_adm/PRY_adm/PRY_adm1.shp", quiet = TRUE)

provincial_limits <- rbind(
  st_sf(geometry = st_geometry(arg_adm1)),
  st_sf(geometry = st_geometry(bol_adm1)),
  st_sf(geometry = st_geometry(pry_adm1))
)

provincial_limits <- st_transform(provincial_limits, crs(r_cont))

national_limits <- rbind(
  st_sf(country = "Argentina", geometry = st_union(st_geometry(arg_adm1))),
  st_sf(country = "Bolivia", geometry = st_union(st_geometry(bol_adm1))),
  st_sf(country = "Paraguay", geometry = st_union(st_geometry(pry_adm1)))
)

national_limits <- st_transform(national_limits, crs(r_cont))


# ---------------------------------------------------------
# 3. Country labels
# ---------------------------------------------------------

country_centroids <- data.frame(
  country = c("AR", "BO", "PY"),
  longitude = c(-65.0, -64.5, -58.5),
  latitude = c(-36.0, -16.5, -23.5)
)

country_centroids <- st_as_sf(
  country_centroids,
  coords = c("longitude", "latitude"),
  crs = 4326
)

country_centroids <- st_transform(country_centroids, crs(r_cont))

country_centroids <- cbind(
  st_drop_geometry(country_centroids),
  st_coordinates(country_centroids)
)


# ---------------------------------------------------------
# 4. Map extent and margins
# ---------------------------------------------------------

map_extent <- ext(r_cont)

x_pad_left  <- (map_extent[2] - map_extent[1]) * 0.06
x_pad_right <- (map_extent[2] - map_extent[1]) * 0.20
y_pad       <- (map_extent[4] - map_extent[3]) * 0.025

# Complete plotting limits
x_min <- map_extent[1] - x_pad_left
x_max <- map_extent[2] + x_pad_right

y_min <- map_extent[3] - y_pad
y_max <- map_extent[4] + y_pad


# ---------------------------------------------------------
# 5. Custom scale bar (500 km)
# ---------------------------------------------------------

# Mean latitude of the mapped area
mean_lat <- mean(c(map_extent[3], map_extent[4]))

# Center of the complete plotting panel
panel_center <- mean(c(x_min, x_max))

# Shift the scale bar slightly to the right
scale_center <- panel_center + 8

# Calculate the endpoints at mean latitude
p_center <- c(scale_center, mean_lat)

p0_reference <- destPoint(
  p = p_center,
  b = 270,
  d = 250000
)

p500_reference <- destPoint(
  p = p_center,
  b = 90,
  d = 250000
)

# Position at the bottom of the map
scale_y <- map_extent[3] - y_pad + 1.2

p0 <- c(p0_reference[1], scale_y)
p250 <- c(scale_center, scale_y)
p500 <- c(p500_reference[1], scale_y)

# Bar dimensions
scale_height <- 0.28

# Labels slightly below the bar
label_y <- scale_y - 0.55

# Move the 500 km label further right
label_500_x <- p500[1] - 0.5


# ---------------------------------------------------------
# 6. Common map elements
# ---------------------------------------------------------

base_map <- list(
  
  # Provincial boundaries
  geom_sf(
    data = provincial_limits,
    fill = NA,
    colour = "grey25",
    linewidth = 0.2,
    inherit.aes = FALSE
  ),
  
  # National boundaries
  geom_sf(
    data = national_limits,
    fill = NA,
    colour = "black",
    linewidth = 0.3,
    inherit.aes = FALSE
  ),
  
  # Map extent
  coord_sf(
    xlim = c(x_min, x_max),
    ylim = c(y_min, y_max),
    expand = FALSE
  ),
  
  # Scale bar: 0-250 km
  annotate(
    "rect",
    xmin = p0[1],
    xmax = p250[1],
    ymin = scale_y,
    ymax = scale_y + scale_height,
    fill = "black",
    colour = "black",
    linewidth = 0.3
  ),
  
  # Scale bar: 250-500 km
  annotate(
    "rect",
    xmin = p250[1],
    xmax = p500[1],
    ymin = scale_y,
    ymax = scale_y + scale_height,
    fill = "white",
    colour = "black",
    linewidth = 0.3
  ),
  
  # Scale bar labels
  annotate(
    "text",
    x = c(p0[1], p250[1], label_500_x),
    y = label_y,
    label = c("0", "250", "500 km"),
    hjust = c(0, 0.5, 0),
    size = 1.8
  ),
  
  # Axis labels
  labs(
    x = "Longitude",
    y = "Latitude"
  ),
  
  # Theme
  theme_grey(base_size = 14),
  
  theme(
    axis.title.x = element_text(
      margin = margin(t = 12)
    ),
    
    axis.title.y = element_text(
      margin = margin(r = 12)
    ),
    
    legend.background = element_rect(
      fill = "white",
      colour = "grey80"
    ),
    
    legend.title = element_text(
      face = "bold",
      size = 9
    ),
    
    legend.text = element_text(size = 8),
    
    legend.key.height = unit(0.35, "cm"),
    legend.key.width = unit(0.40, "cm"),
    legend.spacing.y = unit(0.25, "cm"),
    legend.margin = margin(5, 7, 5, 7)
  )
)


# ---------------------------------------------------------
# 7. Continuous suitability map
# ---------------------------------------------------------

spectral_palette <- colorRampPalette(
  c(
    "#3288BD",
    "#ABDAA4",
    "#FEE08B",
    "#FC8D59",
    "#D53E4F"
  )
)(10)

p_cont <- ggplot() +
  
  geom_spatraster(
    data = r_cont,
    maxcell = 1e6
  ) +
  
  scale_fill_stepsn(
    colours = spectral_palette,
    limits = c(0, 1),
    breaks = seq(0.1, 0.9, 0.1),
    name = "Suitability",
    na.value = "transparent",
    
    guide = guide_coloursteps(
      even.steps = TRUE,
      show.limits = FALSE,
      barheight = unit(3.5, "cm"),
      barwidth = unit(0.45, "cm"),
      ticks = TRUE,
      frame.colour = "grey50"
    )
  ) +
  
  base_map +
  
  geom_text(
    data = country_centroids,
    aes(X, Y, label = country),
    fontface = "bold",
    size = 4
  ) +
  
  theme(
    legend.position = "inside",
    legend.position.inside = c(0.73, 0.20)
  )


# ---------------------------------------------------------
# 8. Binary suitability map
# ---------------------------------------------------------

p_bin <- ggplot() +
  
  geom_spatraster(
    data = r_bin,
    maxcell = 1e6
  ) +
  
  scale_fill_manual(
    values = c(
      "Absence" = "#E8D5B5",
      "Presence" = "#3F6B25"
    ),
    name = "Potential distribution",
    na.value = "transparent",
    na.translate = FALSE
  ) +
  
  base_map +
  
  geom_text(
    data = country_centroids,
    aes(X, Y, label = country),
    fontface = "bold",
    size = 4
  ) +
  
  theme(
    legend.position = "inside",
    legend.position.inside = c(0.69, 0.20)
  )


# ---------------------------------------------------------
# 9. Display individual maps
# ---------------------------------------------------------

p_cont
p_bin


# ---------------------------------------------------------
# 10. Combined map
# ---------------------------------------------------------

p_comb <- (
  p_cont +
    theme(axis.title.x = element_blank())
) |
  (
    p_bin +
      theme(
        axis.title.x = element_blank(),
        axis.title.y = element_blank()
      )
  )

p_longitude <- ggplot() +
  annotate(
    "text",
    x = 0.5,
    y = 0.5,
    label = "Longitude",
    size = 4.5
  ) +
  theme_void()

p_comb <- p_comb / p_longitude +
  plot_layout(heights = c(1, 0.05))


p_comb


# ---------------------------------------------------------
# 11. Export maps
# ---------------------------------------------------------

ggsave(
  "./Contents/01_ENM/04_model_building/map_continuous.png",
  p_cont,
  width = 6,
  height = 7.5,
  dpi = 300
)

ggsave(
  "./Contents/01_ENM/04_model_building/map_binary.png",
  p_bin,
  width = 6,
  height = 7.5,
  dpi = 300
)

ggsave(
  "./Contents/01_ENM/04_model_building/maps_combined.png",
  p_comb,
  width = 12,
  height = 7.5,
  dpi = 300
)

