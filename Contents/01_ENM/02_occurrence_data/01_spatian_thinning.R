rm(list=ls(all=TRUE))

library(tidyverse)
library(sf)
library(magrittr)
library(spThin)
library(dplyr)

setwd("D:/LFLS/Analyses/C_chilensis_EMN")

occ <- read_delim("./Modelado/Occs/C_chilensis.csv", delim = ",") %>% 
thin(loc.data = .,
       long.col = "Lon",
       lat.col = "Lat",
       spec.col = "Species",
       thin.par = 10, reps = 10,
       locs.thinned.list.return = TRUE,
       write.files = TRUE,
       max.files = 10,
       write.log.file = TRUE,
       out.dir = "./Modelado/Occs_thin/",
       out.base = "C_chilensis_thin",
       log.file = "C_chilensis_thin_log.txt")

plotThin(occ)

class(occ)
head(occ)
length(occ$sp)  # 2511
str(occ)

write.csv(occ, "./Occurrences/S_scrofa_thinned.csv", row.names = F) 