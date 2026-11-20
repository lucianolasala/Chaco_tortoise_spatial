rm(list=ls())

library(paisaje)
library(terra)
install.packages("envar")
library(envar)

# Target folder
dir_out <- "D:/CIC/Analisis/C_chilensis_spatial/Chaco_tortoise_spatial/Contents/01_ENM/01_data_preparation/CHELSA_variables"
dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)

#-----------------------------------------------------
# BIO variables
# Bio08, Bio09, Bio18, and Bio19 are excluded from 
# downloads due to inconsistencies in the study region
#-----------------------------------------------------

vars <- paste0("bio", setdiff(1:19, c(8, 9, 18, 19)))

base_url <- paste0(
  "https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/",
  "climatologies/1981-2010/bio/")

options(timeout = 1800)

for (v in vars) {
  filename <- paste0("CHELSA_", v, "_1981-2010_V.2.1.tif")
  url <- paste0(base_url, filename)
  destino <- file.path(dir_out, filename)
  
  # Omitir archivos existentes no vacíos
  if (file.exists(destino) && file.size(destino) > 0) {
    message("Ya existe: ", filename)
    next
  }
  
  message("Descargando: ", filename)
  
  tryCatch({
    
    download.file(
      url,
      destfile = destino,
      mode = "wb",
      method = "libcurl",
      quiet = FALSE)
    
    message("Descarga finalizada: ", filename)
    
  }, error = function(e) {
    
    message("ERROR en ", filename, ": ", conditionMessage(e))
    
    # Eliminar archivos incompletos
    if (file.exists(destino)) {
      file.remove(destino)
    }
    
  })
}

#-----------------------------------------------------
# Surface downwelling shortwave radiation
#-----------------------------------------------------

# Variables de radiación solar
vars <- c("max", "mean", "min", "range")

# Carpeta de destino
dir_out <- "D:/CIC/Analisis/C_chilensis_spatial/Chaco_tortoise_spatial/Contents/01_ENM/01_data_preparation/CHELSA_variables"
dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)

# URL base CHELSA v2.1
base_url <- paste0(
  "https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/",
  "climatologies/1981-2010/bio/")

# Aumentar timeout a 30 minutos
options(timeout = 1800)

# Descargar cada variable por separado
for (v in vars) {
  
  filename <- paste0(
    "CHELSA_rsds_1981-2010_", v, "_V.2.1.tif"
  )
  
  url <- paste0(base_url, filename)
  destino <- file.path(dir_out, filename)
  
  if (file.exists(destino) && file.size(destino) > 0) {
    message("Ya existe: ", filename)
    next
  }
  
  for (intento in 1:3) {
    
    message("Descargando: ", filename,
            " | Intento: ", intento)
    
    resultado <- tryCatch({
      
      estado <- suppressWarnings(
        download.file(
          url,
          destfile = destino,
          mode = "wb",
          method = "libcurl",
          quiet = FALSE
        )
      )
      
      identical(estado, 0L)
      
    }, error = function(e) {
      message("Error: ", conditionMessage(e))
      FALSE
    })
    
    if (resultado) {
      message("Descarga completada: ", filename)
      break
    }
    
    if (file.exists(destino)) file.remove(destino)
    
    Sys.sleep(10)
  }
}
