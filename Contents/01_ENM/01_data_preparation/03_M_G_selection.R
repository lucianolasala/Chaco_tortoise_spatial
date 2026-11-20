#------------------------------------------------------------
# Calibration area Área de calibración (M): ecorregiones 
# con registros de C. chilensis
#------------------------------------------------------------

# Load required packages

rm(list=ls(all=TRUE))

library(terra)
library(dplyr)
library(tidyverse)
library(sf)
library(udunits2)
library(readxl)
library(ggplot2)
library(magrittr)

df <- read_excel("./Contents/01_ENM/02_occurrence_data/Spatial_DB.xlsx", sheet = "C_chilensis_validas"); head(df)
View(df)

write.csv(df, "./Contents/01_ENM/02_occurrence_data/Occs_chilensis.csv", row.names = FALSE)

#------------------------------------------------------------
# C. chilensis 
#------------------------------------------------------------

chilensis <- read_csv("./Contents/01_ENM/02_occurrence_data/Occs_chilensis.csv", 
                      show_col_types = FALSE)  
# readr::read_csv function imports data into R as a tibble

head(chilensis)
st_crs(chilensis)  # No CRS
length(chilensis$Species)  # 845 

# Create a CRS object to define the CRS of our sf object
chilensis_crs <- st_crs(4326)  # Set or replace/retrieve coordinate reference system from object 
st_crs(chilensis_crs)
class(chilensis_crs)  # crs

# Convert our "non-spatial" flat file to a spatially explicit file
# Specify columns containing coordinates and the CRS that the column coordinate represent

chilensis_df <- st_as_sf(chilensis, 
                         coords = c("Lon", "Lat"), 
                         crs = chilensis_crs)  
# File has Lon and Lat columns, which are transformed to "geometry" 
# column through sf

class(chilensis_df)
head(chilensis_df)
st_crs(chilensis_df)  # Check that there exist a CRS
colnames(chilensis_df)
length(chilensis_df$geometry)  # 845

plot(chilensis_df$geometry, col = "blue")

st_write(chilensis_df, "./Contents/01_ENM/02_occurrence_data/Occs_chilensis.gpkg", driver = "gpkg")


#------------------------------------------------------------------------------------
# Extracting ecoregions with C. chilensis
#------------------------------------------------------------------------------------

rm(list=ls(all=TRUE))

chilensis <- read_sf("./Contents/01_ENM/02_occurrence_data/Occs_chilensis.gpkg")

class(chilensis)  # Loads as tibble
head(chilensis)

# Retrieve coordinates in matrix form

chilensis_df <- as.data.frame(sf::st_coordinates(chilensis))  
head(chilensis_df)

colnames(chilensis_df) <- c("Lon", "Lat")  # Name columns Long and Lat
head(chilensis_df)


#------------------------------------------------------------------------------------
# Intersect between world ecorregions and tortoise occurrences
#------------------------------------------------------------------------------------

library(sf)
library(dplyr)

# --------------------------------------------------
# 1. Load occurrence and ecoregion data
# --------------------------------------------------

chilensis <- st_read("./Contents/01_ENM/02_occurrence_data/Occs_chilensis.gpkg")
eco_world <- st_read("./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions/World_ecoregions_fixed.gpkg")

# Controls

valid = st_is_valid(eco_world)
length(valid)  # 14449

which(valid=="FALSE") # 0
which(valid=="TRUE")  # 14449

# --------------------------------------------------
# 2. Harmonize coordinate reference systems
# --------------------------------------------------

chilensis <- st_transform(chilensis, st_crs(eco_world))

# --------------------------------------------------
# 3. Spatial intersection
# --------------------------------------------------

chilensis_eco <- st_join(chilensis,
  eco_world["ECO_NAME"],
  join = st_intersects,
  left = TRUE)

# --------------------------------------------------
# 4. Identify unmatched occurrences
# --------------------------------------------------

unmatched <- chilensis_eco |>
  filter(is.na(ECO_NAME))

cat("Unmatched occurrences:", nrow(unmatched), "\n")

# --------------------------------------------------
# 5. Extract unique ecoregions
# --------------------------------------------------

unique_eco <- chilensis_eco |>
  st_drop_geometry() |>
  filter(!is.na(ECO_NAME)) |>
  distinct(ECO_NAME) |>
  arrange(ECO_NAME)

print(unique_eco)

cat("Number of ecoregions:", nrow(unique_eco), "\n")

# --------------------------------------------------
# 6. Extract corresponding ecoregion polygons
# --------------------------------------------------

eco_selected <- eco_world |>
  filter(ECO_NAME %in% unique_eco$ECO_NAME)

# --------------------------------------------------
# 7. Export
# --------------------------------------------------

write.csv(
  unique_eco,
  file = "./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions/Ecoregions_chilensis.csv",
  row.names = FALSE)

output_dir <- "./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions/"

st_write(
  eco_selected,
  dsn = file.path(output_dir, "Ecoregions_chilensis.gpkg"),
  delete_dsn = TRUE)

# Load ecoregions saved as csv

unique_eco <- read.csv(file = "./datos/Vectores/Ecoregions_chilensis.csv", sep = ",")
unique_eco
unique_eco_map <- eco_world[eco_world$ECO_NAME %in% unique_eco$Ecoregion, ]

plot(unique_eco_map$geom)

class(unique_eco_map)
str(unique_eco_map)
unique_eco_map$ECO_NAME

st_write(unique_eco_map, "./datos/Vectores/Ecoregions_chilensis.gpkg", driver = "gpkg")


# --------------------------------------------------
# Disolve ecoregions
# --------------------------------------------------

chiensis_ecos <- st_read("./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions/Ecoregions_chilensis.gpkg")

dissolved <- chiensis_ecos |>
  st_union() 

dis <- ggplot() +
  geom_sf(data = dissolved, fill = "blue", color = "black") +
  theme_minimal(); dis

st_write(dissolved, "./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions_chilensis_diss.shp", driver = "ESRI Shapefile")


#---------------------------------------------------------------------
# Projection area
#---------------------------------------------------------------------

library(rnaturalearth)
library(rnaturalearthhires)

# Load world ecoregions
eco_world <- st_read("./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions/World_ecoregions_fixed.gpkg")

# Load countries from Natural Earth Data
countries <- ne_countries(scale = "large", returnclass = "sf")
length(countries$admin)

ABP <- countries %>% 
  dplyr::filter(admin %in% c("Argentina", "Bolivia", "Paraguay"))

eco_ABP <- eco_world %>%
  st_make_valid() %>%                          
  st_intersection(ABP) %>%                      
  select(ECO_NAME, geom)

plot(eco_ABP)

# Load ecoregions with occurrence records
ecos_chilensis <- st_read("./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions/Ecoregions_chilensis.gpkg")
names(ecos_chilensis)

# Extract the difference between all ecoregions and calibration area ecoregions
eco_remaining <- eco_ABP %>% 
  filter(!ECO_NAME %in% ecos_chilensis$ECO_NAME)

# Check result
plot(st_geometry(eco_ABP), col="lightgreen", main="Ecoregions AR, BO, PY")
plot(st_geometry(eco_remaining), col="red", add=TRUE)  # remaining ecoregions highlighted

# Dissolve and save both versions (dissolved and undissolved)
dissolved_G <- eco_remaining |>
  st_union()

st_write(eco_remaining,
         "./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions/Ecoregions_wo_chilensis.shp", driver = "ESRI Shapefile")

st_write(dissolved_G,
         "./Contents/01_ENM/01_data_preparation/Vectors/Ecoregions/Ecoregions_wo_chilensis_dis.shp", driver = "ESRI Shapefile")
  