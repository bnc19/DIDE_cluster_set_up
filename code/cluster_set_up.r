# This script shows how to initially set up the cluster and run a demo function. 

# install these 

#install.packages("didehpc")
#install.packages("queuer")
#install.packages("context")
#install.packages("provisionr")
#install.packages("buildr")
#install.packages("syncr")
#install.packages("rrq")

drat:::add("mrc-ide")

options(
  didehpc.username = "bnc19",   # change to your username 
  didehpc.home = "Q:/")    # change letter to match 

didehpc:::didehpc_config(credentials=list(username="bnc19"), home = "Q:/")

root <- "Q:/project_name"
setwd(root)


# here you need to load the packages you use in your function
# test_function.R is where I have the functions I will run 
# make sure the files loaded in ctx are in your current working directory 

ctx <- context::context_save(root,# packages=c(""), 
                             sources="test_function.R")


# here you should be asked to login using your dide username and password
# if you get a message saying you don't have access / your password is wrong 
# check with Wes that you definitely have cluster acess 

obj <- didehpc::queue_didehpc(ctx)  # depending on number of packages this can take a while 

# to run a function on the cluster, we wrap it in obj$enqueue: 

M1 <- obj$enqueue(test_function(2)) # function in test_function.R file (test multiplies x by 2)

M1$status() # tells you the status of your job:

# pending - probably in the queue to be run
# running
# complete 
# failed - check your function runs locally to debug, otherwise could be a memory issue depending on what you're running 

M1$result() # will return what ever your function outputs 

# to list all submitted tasks

obj$task_list()

#to unsubmit
obj$unsubmit(ML$id)
obj$task_delete(ML$id)
