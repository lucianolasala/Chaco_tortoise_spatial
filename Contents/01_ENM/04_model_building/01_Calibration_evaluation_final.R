
# =========================================================
# Model calibration
# =========================================================

# The following code generates candidate models to test multiple parameter 
# combinations, including distinct regularization multiplier values, various 
# feature classes, and different environmental variables in the same set.   

rm(list=ls(all=TRUE))

# Loading libraries

library(kuenm)

setwd("D:/CIC/Analisis/C_chilensis_spatial/Chaco_tortoise_spatial/Contents/01_ENM/04_model_building")

# Loadging occurrence data
occ_joint <- "./Occs/occ_joint_thinned.csv"
occ_tra <- "./Occs/occ_train_thinned.csv"     
M_var_dir <- "M"     
batch_cal <- "Candidate_models"   
out_dir <- "Candidate_models"    
reg_mult <- c(0.1,0.25,0.5,0.75,1,2.5,5)
f_clas <- c("l", "lq", "lqp")
args <- NULL

# Usar ruta absoluta porque tira error
mxpath <- "C:/Program Files/maxent/maxent" 
wait <- TRUE
run <- TRUE

kuenm_cal(occ.joint = occ_joint, occ.tra = occ_tra, M.var.dir = M_var_dir, 
          batch = batch_cal, out.dir = out_dir, 
          reg.mult = reg_mult, f.clas = f_clas, args = args, 
          maxent.path = mxpath, wait = wait, run = run)


#------------------------------------------------------
# Model Evaluation
#------------------------------------------------------

# The following code evaluates candidate models in terms of statistical 
# significance (partial ROC), prediction ability (omission rates), and model 
# complexity (AICc). After evaluation, this function selects the best models 
# based on user-defined criteria.  

cresdir <- "./candidate_models"
occ_joint <- "./Occs/occ_joint_thinned.csv"
occ_tra <- "./Occs/occ_train_thinned.csv"  
occ_test <- "./Occs/occ_test_thinned.csv"
batch_cal <- "./candidate_models"
out_eval <- "./Best_models"

threshold <- 5  # Percentage of training data omission error allowed (E); default = 5
rand_percent <- 50  # Percentage of data to be used for the bootstraping process 
                    # when calculating partial ROCs; default = 50
iterations <- 100
kept <- TRUE
selection <- "OR_AICc"

# Following, kuenm_ceval evaluates candidate models in terms of statistical significance 
# (partial ROC), prediction ability (omission rates), and model complexity (AICc). 
# After evaluation, this function selects the best models based on user-defined criteria.

kuenm_ceval(path = cresdir, occ.joint = occ_joint, occ.tra = occ_tra, 
            occ.test = occ_test, batch = batch_cal, out.eval = out_eval,
            threshold = threshold, rand.percent = rand_percent, iterations = iterations,
            kept = kept, selection = selection)


#------------------------------------------------------
# Creation of final models without projection
#------------------------------------------------------

rm(list=ls(all=TRUE))

occ_joint <- "./datos/occ_joint_thined.csv" 
batch_fin <- "./output/chelsa_5vars/final_models_no_proj"
moddir <- "./output/chelsa_5vars/final_models_no_proj"
M_var_dir <- "output/chelsa_5vars/calibration_m"
out_eval <- "./output/chelsa_5vars/best_models"
args <- NULL
mxpath <- "C:/Users/vazqu/Documents/Uni/Doctorado/enm_cchilensis/maxent"

kuenm_mod(occ.joint = occ_joint, M.var.dir = M_var_dir, out.eval = out_eval, 
          batch = batch_fin, rep.n = 10, args = args, rep.type = "Bootstrap",
          jackknife = TRUE, out.dir = moddir, max.memory = 1000, 
          out.format = "cloglog", project = FALSE, 
          write.mess = FALSE, write.clamp = FALSE, 
          maxent.path = mxpath, wait = FALSE, run = TRUE)


#------------------------------------------------------
# Creation of final models with projection
#------------------------------------------------------

rm(list=ls(all=TRUE))

occ_joint <- "./datos/occ_joint_thined.csv" 
batch_fin <- "./output/chelsa_5vars/final_models_with_proj"
moddir <- "./output/chelsa_5vars/final_models_time_proj"
M_var_dir <- "output/chelsa_5vars/calibration_m"
G_var_dir <- "output/chelsa_5vars/projection_g"
out_eval <- "./output/chelsa_5vars/best_models"
args <- NULL
mxpath <- "C:/Users/vazqu/Documents/Uni/Doctorado/enm_cchilensis/maxent"

kuenm_mod(occ.joint = occ_joint, M.var.dir = M_var_dir, 
          G.var.dir = G_var_dir, ext.type = "ext", out.eval = out_eval, 
          batch = batch_fin, rep.n = 10, args = args, rep.type = "Bootstrap",
          jackknife = TRUE, out.dir = moddir, max.memory = 1000, 
          out.format = "cloglog", project = TRUE, 
          write.mess = FALSE, write.clamp = FALSE, 
          maxent.path = mxpath, wait = FALSE, run = TRUE)
