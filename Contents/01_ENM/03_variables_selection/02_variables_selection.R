#------------------------------------------------------------------------------------
# Correlation analysis for variable selection
#------------------------------------------------------------------------------------

gc()
rm(list=ls(all=TRUE))

install.packages("openxlsx")

library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(sf) # Simple Features for R
library(stars) # Spatiotemporal Arrays, Raster and Vector Data Cubes
library(magrittr) # A Forward-Pipe Operator for R
library(raster) # Geographic Data Analysis and Modeling
library(writexl) # Read, Write, Format Excel 2007 and Excel 97/2000/XP/2003 Files
library(corrplot) # Visualization of a Correlation Matrix
library(ggcorrplot) # Visualization of a Correlation Matrix using 'ggplot2'
library(openxlsx)

#------------------------------------------------------------------------
# Check spatial resolution and raster extent for M layers
#------------------------------------------------------------------------

path = ("./datos/M_ascii") 
files <- list.files(path = path, pattern = ".asc$", full.names = TRUE)
files  # 11

mytable <- NULL

for(i in 1:length(files)){
  r <- raster(files[i])
  mytable <- rbind(mytable, c(files[i], round(c(res(r), as.vector(extent(r))), 16)))
}

colnames(mytable) <- c("File","Resol.x","Resol.y","xmin","xmax","ymin","ymax")
class(mytable)
mytable <- as.data.frame(mytable)

write_xlsx(mytable, "./output/cor_variables/Rasters_props_M.xlsx")


#----------------------------------------------------------------
# Correlation. Uso de funcion cor en stats
#----------------------------------------------------------------

library(terra)

rm(list=ls(all=TRUE))


path = ("./datos/M_ascii")
files <- list.files(path = path, pattern = ".asc$", full.names = T)
files

r <- rast(files)

vals <- values(r)

# filtrar celdas completas (sin NA en ninguna capa)
k <- which(complete.cases(vals))

# sampleo
k.samp <- sample(k, size = round(length(k) * 0.1))

# extraer
k.final <- vals[k.samp, ]

# check
sum(is.na(k.final))  # debería dar 0

cor.matrix <- cor(k.final, use = "pairwise.complete.obs", method = "pearson")  
head(cor.matrix)
dim(cor.matrix)  # 11*11
is.matrix(cor.matrix)  # TRUE

write.table(cor.matrix, "./output/cor_variables/Cor_matrix1.csv", 
            row.names=FALSE, 
            col.names=FALSE, sep = ',')

write.csv(cor.matrix, "./output/cor_variables/Cor_matrix2.csv")

# Plot correlation matrix for entire set of variables
# La fc corrplot tiene que correr sobre una matriz

install.packages("corrplot")
library(corrplot)

plot.new()
corr_plot <- corrplot(cor.matrix, method = "color", type = "lower", 
             mar = c(1,1,1,1), 
             order = "alphabet", 
             tl.col = "black", 
             tl.cex = 0.5, 
             is.corr = FALSE)

# Save output matrix as dataframe (Excel and csv) with rows and columns names
DF <- as.data.frame(cor.matrix)

# Add names to columns and rows
files.1 <- list.files(path = path, pattern = ".asc$", full.names = F)
is.vector(files.1)

colnames(DF) <- files.1
rownames(DF) <- files.1
head(DF)

openxlsx::write.xlsx(DF,"./output/cor_variables/Cor_matrix.xlsx", 
                     rowNames = TRUE, 
                     colNames=T, 
                     overwrite = TRUE)


#-------------------------------------------------------------------------
# Introduction to Feature selection for bioinformaticians using R, 
# correlation matrix filters, PCA & backward selection
# https://www.r-bloggers.com/2013/10/introduction-to-feature-selection-for-bioinformaticians-using-r-correlation-matrix-filters-pca-backward-selection/
#-------------------------------------------------------------------------

gc()
rm(list=ls(all=TRUE))

install.packages("caret")
library(caret) # Classification and Regression Training

DF <- read.table("./output/cor_variables/Cor_matrix1.csv", sep = ',')

is.data.frame(DF)
ncol(DF)
nrow(DF)
dim(DF)
colnames(DF)
rownames(DF)

# La matriz DF es la matriz de correlacion anterior que tiene todos los valores de
# correlacion. The function findCorrelation searches through a "correlation matrix" and returns a 
# vector of integers corresponding to columns to remove to reduce pair-wise correlations.
# Apply correlation filter at 0.8

DF.mat <- as.matrix(DF)
is.matrix(DF.mat)
dim(DF.mat)

highlyCor <- findCorrelation(cor(as.matrix(DF.mat)), # x has to be matrix
                             cutoff = 0.8, 
                             exact = TRUE) 

highlyCor  # 7 5 9 3 2 10 11 (7 columns to remove)
length(highlyCor)  # 7

filtered <- DF.mat[,-highlyCor]
class(filtered)
dim(filtered)  # 11  4 (10 removed)

filtered
colnames(filtered)  # "V1"  "V4"  "V6"  "V8" 

# Como colnames no tiene nombre claro, asignarlos

path = ("./datos/M_ascii")

files <- gsub("//.asc$","", list.files(path = path, pattern = ".asc$", full.names = F))
files

colnames(DF.mat) <- files
rownames(DF.mat) <- files
head(DF.mat)

# "V1"  "V4"  "V6"  "V8"

mat_keep_rows <- c("BIO1_day_mean_temp.asc","BIO5_day_max_warmest_month.asc",
                   "DEM.asc","Land_Cover.asc")

mat_keep_cols <- c("BIO1_day_mean_temp.asc","BIO5_day_max_warmest_month.asc",
                   "DEM.asc","Land_Cover.asc")

mat_subset <- DF.mat[rownames(DF.mat) %in% mat_keep_rows, 
                     colnames(DF.mat) %in% mat_keep_cols]  # Extract rows from matrix
mat_subset  # matrix
mat_subset_DF <- as.data.frame(mat_subset)
is.data.frame(mat_subset_DF)

openxlsx::write.xlsx(mat_subset_DF, "./output/cor_variables/Matrix_subset.xlsx", 
                     rowNames=T, 
                     colNames=T)

# Plot

corrplot(mat_subset, method = "color", 
         type = "lower", 
         mar = c(1,1,1,1), 
         order = "alphabet", 
         tl.col = "black", 
         tl.cex = 0.6, 
         is.corr = FALSE)
        
# Using ggcorplot

png(height=800, width=800, file="./output/cor_variables/Cor_plot_final.png", 
    type = "cairo")

ggcorrplot(mat_subset, method = "square", type = "lower", ggtheme = ggplot2::theme_minimal, title = "",
           show.legend = F, show.diag = FALSE,
           colors = c("blue", "white", "red"), outline.color = "gray",
           hc.order = FALSE, hc.method = "complete", lab = T,
           lab_col = "black", lab_size = 7, p.mat = NULL, sig.level = 0.05,
           insig = c("pch", "blank"), pch = 4, pch.col = "black",
           pch.cex = 5, tl.cex = 20, tl.col = "black", tl.srt = 45,
           digits = 2)

dev.off()





