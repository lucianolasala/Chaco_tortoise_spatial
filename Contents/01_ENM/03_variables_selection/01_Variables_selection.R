# =========================================================
# Correlation analysis for variable selection
# =========================================================

gc()
rm(list=ls(all=TRUE))

library(tidyverse) 
library(sf) 
library(stars) 
library(magrittr) 
library(raster) 
library(writexl) 
library(corrplot) 
library(ggcorrplot) 
library(openxlsx)

# =========================================================
# Verify raster geometry
# =========================================================

path = ("./Contents/01_ENM/01_data_preparation/CHELSA_all_correlation") 
files <- list.files(path = path, pattern = ".asc$", full.names = TRUE)
files  # 21

mytable <- NULL

for(i in 1:length(files)){
  r <- raster(files[i])
  mytable <- rbind(mytable, c(files[i], round(c(res(r), as.vector(extent(r))), 21)))
}

colnames(mytable) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")
class(mytable)
mytable <- as.data.frame(mytable)

write_xlsx(mytable, "./Contents/01_ENM/03_variables_selection/Correlation_outputs/Rasters_props_M.xlsx")


# =========================================================
# Correlation. Uso de funcion cor en stats
# =========================================================

r <- rast(files)
vals <- values(r)

# filtrar celdas completas (sin NA en ninguna capa)
k <- which(complete.cases(vals))

# Sampling
k.samp.10 <- sample(k, size = round(length(k) * 0.1))
k.samp.10

# Extract
k.final <- vals[k.samp.10, ]

# check
sum(is.na(k.final))  # Needs to be 0

cor.matrix <- cor(k.final, method = "pearson") 
head(cor.matrix)
dim(cor.matrix)  # 21*21
is.matrix(cor.matrix)  # TRUE

write.table(cor.matrix, "./Contents/01_ENM/03_variables_selection/Correlation_outputs/Cor_matrix1.csv", 
            row.names=FALSE, 
            col.names=FALSE, sep = ',')

write.csv(cor.matrix, "./Contents/01_ENM/03_variables_selection/Correlation_outputs/Cor_matrix2.csv")

# =========================================================
# Save output matrix as dataframe (Excel and csv) with 
# rows and columns names
# =========================================================

DF <- as.data.frame(cor.matrix)

# Add names to columns and rows
files.1 <- list.files(path = path, pattern = ".asc$", full.names = F)
is.vector(files.1)

# Extract variable names without .asc
variables <- tools::file_path_sans_ext(basename(files))

colnames(DF) <- variables
rownames(DF) <- variables
head(DF)

openxlsx::write.xlsx(DF,"./Contents/01_ENM/03_variables_selection/Correlation_outputs/Cor_matrix.xlsx", 
                     rowNames = TRUE, 
                     colNames=T, 
                     overwrite = TRUE)


# =========================================================
# Plot correlation matrix for entire set of variables
# La fc corrplot tiene que correr sobre una matriz
# =========================================================

plot.new()

# Output directory
dir_out <- "./Contents/01_ENM/03_variables_selection/Correlation_outputs"
dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)

# Open PNG graphics device
png(filename = file.path(dir_out, "Correlation_plot.png"),
    width = 2400,
    height = 2200,
    res = 300)

corr_plot <- corrplot(cor.matrix, method = "color", type = "lower", 
             mar = c(1,1,1,1), 
             order = "alphabet", 
             tl.col = "black", 
             tl.cex = 0.5, 
             is.corr = FALSE)


# Close graphics device and save file
dev.off()
message("Correlation plot exported successfully.")





