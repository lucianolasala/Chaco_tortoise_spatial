#------------------------------------------------------------------------
# Check spatial resolution and raster extent for layers
#------------------------------------------------------------------------

path = ("D:/LFLS/Analyses/MNE_garrapatas/Modelado_turicata/Rasters/Calibration_ascii") 

files <- list.files(path = path, pattern = ".asc$", full.names = TRUE)
files  # 22

mytable <- NULL

for(i in 1:length(files)){
  r <- raster(files[i])
  mytable <- rbind(mytable, c(files[i], round(c(res(r), as.vector(extent(r))), 16)))
}

colnames(mytable) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")
mytable
mytable <- as.data.frame(mytable)

write_xlsx(mytable, "D:/Trabajo/Analisis/MNE_garrapata/Rasters/Calibration_ascii_props/Rasters_props.xlsx")
