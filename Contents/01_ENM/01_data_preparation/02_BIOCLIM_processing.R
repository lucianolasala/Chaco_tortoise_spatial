
# =========================================================
# Processing CHELSA remote sensing products by cropping 
# and masking layers to ecoregions assigning NA outside 
# and keeping vals inside
# =========================================================

rm(list=ls(all=TRUE))

library(terra)
library(dplyr)
library(tidyverse)

# =========================================================
# CALIBRATION AREA
# =========================================================

m <- vect("./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions/Ecoregions_chilensis_diss.gpkg")

# Input directory
dir_in <- "./Contents/01_ENM/01_data_preparation/CHELSA_bio_raw"

# Output directory
dir_out <- "./Contents/01_ENM/01_data_preparation/CHELSA_BIOCLIM_crop_M"
dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)

# Load raster files and stack
files <- list.files(
  dir_in,
  pattern = "\\.tif$",
  full.names = TRUE); files

# 2. Crear SpatRaster
stack <- rast(files)

# Asegurar mismo CRS
if (!crs(stack) == crs(m)) {
  m <- project(m, crs(stack))
}

# 4. Crop + mask
masked <- mask(crop(stack, m), m)

# 5. Separar capas
ind_r <- as.list(masked)

# 6. Nombres
variables <- c(
  "BIO_01","BIO_02","BIO_03","BIO_04","BIO_05","BIO_06","BIO_07",
  "BIO_10","BIO_11","BIO_12","BIO_13","BIO_14","BIO_15","BIO_16",
  "BIO_17")

# Chequeo (MUY importante)
stopifnot(length(ind_r) == length(variables))

# =========================================================
# Export CHELSA BIO variables as ASCII grids
# =========================================================

# =========================================================
# Extract and format BIO variable names
# =========================================================

# Extract BIO numbers from original filenames
bio_num <- as.integer(
  sub(".*CHELSA_bio([0-9]+)_.*", "\\1", basename(files)))

# Format names with two digits
variables <- sprintf("BIO%02d", bio_num)

# Assign names to raster layers
names(masked) <- variables

# Export
for (nm in names(masked)) {
  
  writeRaster(
    masked[[nm]],
    filename = file.path(dir_out, paste0(nm, ".asc")),
    filetype = "AAIGrid",
    overwrite = TRUE,
    NAflag = -9999
  )
  
  message("Exported: ", nm, ".asc")
}

message("All CHELSA BIO variables exported successfully.")


# =========================================================
# PROJECTION AREA
# =========================================================

g <- vect("./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions/Ecoregions_wo_chilensis_dis.gpkg")

# Input directory
dir_in <- "./Contents/01_ENM/01_data_preparation/CHELSA_bio_raw"

# Output directory
dir_out <- "./Contents/01_ENM/01_data_preparation/CHELSA_BIOCLIM_crop_G"
dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)

# Load raster files and stack
files <- list.files(
  dir_in,
  pattern = "\\.tif$",
  full.names = TRUE); files

# 2. Crear SpatRaster
stack <- rast(files)

# Asegurar mismo CRS
if (!crs(stack) == crs(g)) {
  m <- project(g, crs(stack))
}

# 4. Crop + mask
masked <- mask(crop(stack, g), g)

# 5. Separar capas
ind_r <- as.list(masked)

# 6. Nombres
variables <- c(
  "BIO_01","BIO_02","BIO_03","BIO_04","BIO_05","BIO_06","BIO_07",
  "BIO_10","BIO_11","BIO_12","BIO_13","BIO_14","BIO_15","BIO_16",
  "BIO_17")

# Chequeo (MUY importante)
stopifnot(length(ind_r) == length(variables))


# =========================================================
# Export CHELSA BIO variables as ASCII grids
# =========================================================

# Extract variable names from original filenames
variables <- sub(".*CHELSA_bio([0-9]+)_.*", "BIO\\1", basename(files))

# Assign names to raster layers
names(masked) <- variables

# Export
for (nm in names(masked)) {
  
  writeRaster(
    masked[[nm]],
    filename = file.path(dir_out, paste0(nm, ".asc")),
    filetype = "AAIGrid",
    overwrite = TRUE,
    NAflag = -9999
  )
  
  message("Exported: ", nm, ".asc")
}

message("All CHELSA BIO variables exported successfully.")