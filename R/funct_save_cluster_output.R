save_cluster_output = function(task_bundle_name, output_path = "output") {
 
   # load package
  library(tidyverse)
  
  # create folder to save results 
  dir.create(output_path)
  
  # extract results from each task bundle 
  all_tasks  = obj$task_bundle_get(task_bundle_name)
  results = all_tasks$results()
 
  summarise_results  =  
    results %>%  bind_rows() %>%  # merge the results from all 100 jobs to one data.frame 
    group_by(split, metric) %>% 
    summarise(mean = mean(value), # calclate mean and 95% C()
              lower = quantile(value, p = 0.025),
              upper = quantile(value, p = 0.975)) 

 
  # save files 
  
  write.csv(summarise_results, 
            file = paste0(output_path, "summarise_results.csv"))  
  
  
  return(summarise_results) } 
