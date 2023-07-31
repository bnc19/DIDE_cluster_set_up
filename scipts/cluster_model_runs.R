# This script gives an example for running multiple jobs on the cluster. 

# In this example I'm going to predict the infecting dengue serotype from 
# neutralising antibody titres, using multinomial logistic regression (MLR) and
# the machine learning algorithm random forest (RF). 

# I want to run each model 100 times to calculate a boostrap 95% CI, so I'm going
# to use the cluster so I can run all those jobs at once. I can also change 
# parameter values and run those model variants at the same time. 

# You can look at the code that runs the model fitting if you want, but the main 
# purpose is to demonstrate running multiple jobs on the cluster. The code itself
# and the model fitting is not important. 

# Set up cluster ---------------------------------------------------------------

root = "Q:/DIDE_cluster_set_up" 
setwd(root)

# packages and function we want to run on the cluster 
ctx <- context::context_save(root,  
                            packages=c("caret", "e1071", "nnet",
                                       "ranger", "tidyverse"), 
                            sources=c("R/funct_model_fitting.R")) # function 


# This function uses quite a bit of memory so I set the number of cores used 
# per job to 2 
config <- didehpc::didehpc_config(cores = 2,  parallel = F)

# You might also increase the number of cores and set parallel = T for parallel
# computation 

# Create a queue within the context 
obj <- didehpc::queue_didehpc(ctx, config) 

# Import data ------------------------------------------------------------------

# outcome data 
all_outcome <- as.factor(read.csv("data/all_outcome.csv")$x)

# predictors data 
pre_post_change_date_pred <- read.csv("data/pre_post_change_date_pred.csv")[,-1]

# load the function which will save our results 
source("R/funct_save_cluster_output.R") 

# Run the models ---------------------------------------------------------------

# The lapply function on the cluster works like lapply when used locally. 
# We're applying our function (run_model) to each element of a list. Here, I am
# running the function 100 times using all the same parameter values (achieved
# by repeating 1, 100 times.)

# If you wanted to run your function using each row in a data.frame as input, 
# you could set X = data.frame$column_name. 


# run the random forest model 100 times 

M1 <-  obj$lapply(X = rep(1,100),
                FUN = run_model,
                classifier_name= "rf",
                model_predictors = pre_post_change_date_pred,
                model_outcome = all_outcome,
                split_prop = 0.9,
                Seed = 1,
                primary = F,
                name = "rf")

# When you run this, you will see each of the 100 jobs being submitted to the 
# cluster to run. These are sent as a task bundle. I've named that task bundle
# "rf" using the name argument. If you don't set a name, an automated name
# is generated for you. 

M1$status() # run to check the status of each of your 100 tasks

# This also shows the names of each individual task. If one task has finished 
# and you want to access it whilst the rest are running, you can:

task1 <- obj$task_get("c4fea844952c536b08e0e1c7d9c7c9f1") # update the task id 

task1$result()

# If a task is running or it fails you can check the log to see what code is 
# being outputted: 

task1$log()

# If your job does fail, check it runs locally as it is much easier to debug 
# from there Sometimes jobs do just fail. Sometimes it's memory (try increasing 
# cores). 


# If your computer were to crash now, you would probably find that the object 
# M1 wasn't saved and you could no longer access your task bundle. 

# As long as you've made a note of your task bundle name, this doesn't matter as  
# you can access it by running:

M1 <- obj$task_bundle_get("rf") # or whatever you name your task bundle 


# Next, I also want to fit the model using MLR 100 times, which I can do at the  
# same time as the RF above:

M2 <-  obj$lapply(X = rep(1,100),
                  FUN = run_model,
                  classifier_name= "mlr", # changed this argument to mlr 
                  model_predictors = pre_post_change_date_pred,
                  model_outcome = all_outcome,
                  split_prop = 0.9,
                  Seed = 1,
                  primary = F,
                  name = "mlr")

# Now I also want to run both models again, but this time setting split_prop = 
# 0.8. This is very easily done:

M3 <-  obj$lapply(X = rep(1,100),
                  FUN = run_model,
                  classifier_name= "rf",
                  model_predictors = pre_post_change_date_pred,
                  model_outcome = all_outcome,
                  split_prop = 0.8, # changed this argument 
                  Seed = 1,
                  primary = F,
                  name = "rf_0.8")


M4 <-  obj$lapply(X = rep(1,100),
                  FUN = run_model,
                  classifier_name= "mlr",
                  model_predictors = pre_post_change_date_pred,
                  model_outcome = all_outcome,
                  split_prop = 0.8, # changed this argument 
                  Seed = 1,
                  primary = F,
                  name = "mlr_0.8")


# saving model results ---------------------------------------------------------

# e.g. save results of mlr 
save_cluster_output(task_bundle_name = "mlr", 
                    output_path = "output")

# this function extracts the results of all 100 runs, summarises them and then 
# saves them as CSV file in a directory called output. 

# have a look at the code underneath to see how to extract and merge the results 

save_cluster_output 
