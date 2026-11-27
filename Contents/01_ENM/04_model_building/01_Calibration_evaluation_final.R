
# =========================================================
# Model calibration
# =========================================================

# The following code generates candidate models to test multiple parameter 
# combinations, including distinct regularization multiplier values, various 
# feature classes, and different environmental variables in the same set.   

rm(list=ls(all=TRUE))


# Loading libraries

library(kuenm)

setwd("./Contents/01_ENM/04_model_building")

# Loading occurrence data
occ_joint <- "./Contents/01_ENM/02_occurrence_data/occ_joint.csv"
occ_tra <- "./Contents/01_ENM/02_occurrence_data/occ_train.csv"     
M_var_dir <- "M"     
batch_cal <- "./candidate_models"   
out_dir <- "./candidate_models"    
reg_mult <- c(0.1,0.25,0.5,0.75,1,2.5,5)
f_clas <- c("l", "lq", "lqp")
args <- NULL

# Usar ruta absoluta
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

cresdir <- "candidate_models"
occ_joint <- "./Contents/01_ENM/02_occurrence_data/occ_joint.csv"
occ_tra <- "./Contents/01_ENM/02_occurrence_data/occ_train.csv"
occ_test <- "./Contents/01_ENM/02_occurrence_data/occ_test.csv"
batch_cal <- "./candidate_models"
out_eval <- "./best_models"

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

occ_joint <- "./Contents/01_ENM/02_occurrence_data/occ_joint.csv"
batch_fin <- "./final_models_no_proj"
moddir <- "./final_models_no_proj"
M_var_dir <- "M"
out_eval <- "./best_models"
args <- NULL

mxpath <- "C:/Program Files/maxent/maxent" 

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

occ_joint <- "./Contents/01_ENM/02_occurrence_data/occ_joint.csv"
batch_fin <- "./final_models_with_proj"
moddir <- "./final_models_with_proj"
M_var_dir <- "M"
G_var_dir <- "G"
out_eval <- "./best_models"
args <- NULL
mxpath <- "C:/Program Files/maxent/maxent" 

kuenm_mod(occ.joint = occ_joint, M.var.dir = M_var_dir, 
          G.var.dir = G_var_dir, ext.type = "ext", out.eval = out_eval, 
          batch = batch_fin, rep.n = 10, args = args, rep.type = "Bootstrap",
          jackknife = TRUE, out.dir = moddir, max.memory = 1000, 
          out.format = "cloglog", project = TRUE, 
          write.mess = FALSE, write.clamp = FALSE, 
          maxent.path = mxpath, wait = FALSE, run = TRUE)
