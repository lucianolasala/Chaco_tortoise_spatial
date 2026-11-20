
# =========================================================
# Derivar variables a partir de climatologías mensuales
# CHELSA v2.1 | RSDS | 1981–2010
# =========================================================

rm(list = ls())
library(terra)
library(sf)

# =========================================================
# CALIBRATION AREA
# =========================================================

m <- vect("./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions/Ecoregions_chilensis_diss.gpkg")

# Input directory
dir_in <- "./Contents/01_ENM/01_data_preparation/CHELSA_RSDS_raw"

# Output directory
dir_out <- "./Contents/01_ENM/01_data_preparation/CHELSA_RSDS_estimates_crop_M"
dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)

# =========================================================
# Load 12 monthly products
# =========================================================

# List monthly files
files <- list.files(
  dir_in,
  pattern = "\\.tif$",
  full.names = TRUE)

# Sort chronologically
files <- sort(files)

# Check number of monthly products
stopifnot(length(files) == 12)

# Load rasters
rsds <- rast(files)
names(rsds) <- paste0("RSDS_", sprintf("%02d", 1:12))
print(rsds)

# Transform to RSDS CRS
m <- project(m, crs(rsds))

# Crop and mask
rsds_m <- mask(crop(rsds, m), m)


# =========================================================
# Derive variables
# =========================================================

# Annual mean
RSDS_mean <- mean(rsds_m, na.rm = TRUE)

# Monthly maximum
RSDS_max <- max(rsds_m, na.rm = TRUE)

# Monthly minimum
RSDS_min <- min(rsds_m, na.rm = TRUE)

# Standard deviation (seasonal)
RSDS_sd <- app(rsds_m, sd, na.rm = TRUE)

# Coefficient of variation (%)
RSDS_cv <- ifel(RSDS_mean > 0,
                100 * RSDS_sd / RSDS_mean, NA)

# Annual range (seasonal amplitude)
RSDS_range <- RSDS_max - RSDS_min


# =========================================================
# Export derived variables as ASCII grids
# =========================================================

outputs <- list(
  RSDS_mean  = RSDS_mean,
  RSDS_max   = RSDS_max,
  RSDS_min   = RSDS_min,
  RSDS_sd    = RSDS_sd,
  RSDS_cv    = RSDS_cv,
  RSDS_range = RSDS_range
)

for (nm in names(outputs)) {
  
  writeRaster(
    outputs[[nm]],
    filename = file.path(dir_out, paste0(nm, ".asc")),
    filetype = "AAIGrid",
    overwrite = TRUE,
    NAflag = -9999
  )
  
  message("Exported: ", nm, ".asc")
}

message("All RSDS variables exported successfully.")


# =========================================================
# PROJECTION AREA
# =========================================================

g <- vect("./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions/Ecoregions_wo_chilensis_dis.gpkg")

# Input directory
dir_in <- "./Contents/01_ENM/01_data_preparation/CHELSA_RSDS_raw"

# Output directory
dir_out <- "./Contents/01_ENM/01_data_preparation/CHELSA_RSDS_estimates_crop_G"
dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)

# =========================================================
# Load 12 monthly products
# =========================================================

# List monthly files
files <- list.files(
  dir_in,
  pattern = "\\.tif$",
  full.names = TRUE)

# Sort chronologically
files <- sort(files); files

# Check number of monthly products
stopifnot(length(files) == 12)

# Load rasters
rsds <- rast(files)
names(rsds) <- paste0("RSDS_", sprintf("%02d", 1:12))
print(rsds)

# Transform to RSDS CRS
g <- project(g, crs(rsds))

# Crop and mask
rsds_g <- mask(crop(rsds, g), g)


# =========================================================
# Derive variables
# =========================================================

# Annual mean
RSDS_mean <- mean(rsds_g, na.rm = TRUE)

# Monthly maximum
RSDS_max <- max(rsds_g, na.rm = TRUE)

# Monthly minimum
RSDS_min <- min(rsds_g, na.rm = TRUE)

# Standard deviation (seasonal)
RSDS_sd <- app(rsds_g, sd, na.rm = TRUE)

# Coefficient of variation (%)
RSDS_cv <- ifel(RSDS_mean > 0,
                100 * RSDS_sd / RSDS_mean, NA)

# Annual range (seasonal amplitude)
RSDS_range <- RSDS_max - RSDS_min


# =========================================================
# Export derived variables as ASCII grids
# =========================================================

outputs <- list(
  RSDS_mean  = RSDS_mean,
  RSDS_max   = RSDS_max,
  RSDS_min   = RSDS_min,
  RSDS_sd    = RSDS_sd,
  RSDS_cv    = RSDS_cv,
  RSDS_range = RSDS_range
)

for (nm in names(outputs)) {
  
  writeRaster(
    outputs[[nm]],
    filename = file.path(dir_out, paste0(nm, ".asc")),
    filetype = "AAIGrid",
    overwrite = TRUE,
    NAflag = -9999
  )
  
  message("Exported: ", nm, ".asc")
}

message("All RSDS variables exported successfully.")
