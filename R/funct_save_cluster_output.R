save_cluster_output = function(task_bundle_name, output_path = "output") {
 
   # load package
  library(tidyverse)
  
  # create folder to save results 
  dir.create(output_path)
  
  # extract results from each task bundle 
  all_tasks  = obj$task_bundle_get(task_bundle_name)

  results = all_tasks$results() 
 
  
# The function run_model returns a single data.frame, the object results is a 
# list of 100 data.frames. Therefore we can easily merge the results from all
# 100 jobs to one data.frame using the bind_rows function: 

  summarise_results  =  
    results %>%  bind_rows() %>% 
    group_by(split, metric) %>% 
    summarise(mean = mean(value), # calclate mean and 95% C()
              lower = quantile(value, p = 0.025),
              upper = quantile(value, p = 0.975)) 

 
  # save files 
  
  write.csv(summarise_results, 
            file = paste0(output_path, "/", task_bundle_name, "_results.csv"))  
  
  
  return(summarise_results) } 
