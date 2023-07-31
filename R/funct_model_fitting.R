# create partitions of test and train data 

format_train_test_data = function(model_predictors,
                                  model_outcome,
                                  split_prop) {
  
  library(caret)
  library(dplyr)
  
  # split data
  partition = createDataPartition(model_outcome, p = split_prop)
  
  # extract training and test predictors 
  train_predictors =  model_predictors[partition$Resample1, ]
  test_predictors =   model_predictors[-partition$Resample1,]
  
  # extract training and test outcome  
  train_outcome = model_outcome[partition$Resample1]
  test_outcome =  model_outcome[-partition$Resample1]
  
  out = list(train_predictors, test_predictors, train_outcome, test_outcome)
  names(out) = c("train_predictors", "test_predictors", "train_outcome", "test_outcome")
  return(out)
}

# run classifier models using train and test data 

fit_model = function(classifier_name,
                     train_predictors,
                     train_outcome,
                     test_predictors,
                     test_outcome,
                     Seed,
                     primary
)
{
  # This function fits one classifier on the current training data
  # hyperparameters are tuned through LOOCV
  
  
  source('R/funct_RF.R')
  source('R/funct_MLR.R')
  source('R/funct_get_CM.R')
  
  
  # given the classifier name, fit the correct model
  model_fit = switch(
    classifier_name,
    rf = fitRf(train_predictors, train_outcome, Seed),
    gbm = fitgbm (train_predictors, train_outcome, Seed, primary),
    nnet = fitNnet(train_predictors, train_outcome, Seed, primary),
    svm_poly = fit_svm_poly(train_predictors, train_outcome, Seed, primary),
    svm_rad = fit_svm_rad(train_predictors, train_outcome, Seed, primary),
    xgboost = fit_xgb(train_predictors, train_outcome, Seed),
    mlr = fitlmr(train_predictors, train_outcome, Seed)
  )
  
  # retrieve the highest performance values achieved by a hyper-parameter search
  trainCM = get_CM(model_fit, classifier_name, train_outcome)
  
  # predict on test data
  test_out = predict(model_fit, test_predictors)

  
  # test_outcome = droplevels(test_outcome) don't think I need to remove levels
  # test_out = droplevels(test_out)
  
  if (classifier_name == "xgboost") {
    test_outcome = as.factor(as.numeric(test_outcome) - 1)
    
    if (primary == TRUE) {
      levels(test_outcome) = c(1, 2, 0)
    } else{
      levels(test_outcome) = c(1, 2, 3, 0)
    }
    
  }
  
  testCM = confusionMatrix(test_out, test_outcome)
  
  testing_df = 
    data.frame(
      test_predictors,
      test_outcome = test_outcome,
      test_predicted = test_out
    )
  
  
  out = list(model_fit, trainCM, testCM, testing_df)
  names(out) = c("model_fit", "trainCM", "testCM", "testing_df")
  return(out)
}


# calculate weighted average from class specific metrics 


weighted_av = function(class_data, train_CM_tab, test_CM_tab = NULL){
# number in each class- weights 

train_N = train_CM_tab %>%
  as.data.frame() %>%
  group_by(Reference) %>%
  summarise(N = sum(Freq)) %>%
  mutate(serotype = ifelse(Reference == "four" | Reference == 4 , 4,
                           ifelse(
                             Reference == "three"| Reference == 3 , 3,
                             ifelse(
                               Reference == "two"| Reference == 2, 2,
                                    ifelse(
                                      Reference == "one"| Reference == 1, 1,NA)
                           )))) %>%
  arrange(serotype)

if(is.null(test_CM_tab)){
  out  = class_data %>%  
    mutate(serotype = ifelse(class == "four", 4,
                             ifelse(
                               class == "three", 3,
                               ifelse(class == "two", 2, 1)
                             ))) %>% 
    arrange(split,serotype) %>%  
    mutate(N = train_N$N) %>% 
    dplyr::summarise(across(Sensitivity:'Balanced Accuracy',~ 
                              weighted.mean(., w = N , na.rm = T))) %>% 
    mutate(split = "train")
} else{
  
  
  test_N = test_CM_tab %>%
    as.data.frame() %>%
    group_by(Reference) %>%
    summarise(N = sum(Freq)) %>%
    mutate(serotype = ifelse(Reference == "four", 4,
                             ifelse(
                               Reference == "three", 3,
                               ifelse(Reference == "two", 2, 1)
                             ))) %>%
    arrange(serotype)
  
  
  out  = class_data %>%  
    mutate(serotype = ifelse(class == "four", 4,
                             ifelse(
                               class == "three", 3,
                               ifelse(class == "two", 2, 1)
                             ))) %>% 
    arrange(split,serotype) %>%  
    mutate(N = c(test_N$N, train_N$N)) %>%  
    group_by(split) %>%  
    dplyr::summarise(across(Sensitivity:'Balanced Accuracy',~ 
                              weighted.mean(., w = N , na.rm = T))) 
}

 
return(out)
}

# overall function to run model fitting (on the cluster)
 # splits data 
 # runs the classifier
 # extracts training and test performance 
 # returns a data frame of performance metrics 

run_model = function(classifier_name,
                     model_predictors,
                     model_outcome,
                     split_prop,
                     Seed,
                     repeats,
                     primary) {
  
  library(tidyverse)
  library(caret)
  
  data = format_train_test_data(model_predictors, model_outcome, split_prop) 
  
  
  train_predictors = data$train_predictors
  train_outcome = data$train_outcome
  test_predictors = data$test_predictors
  test_outcome = data$test_outcome
  
  
  results = fit_model(
    classifier_name = classifier_name,
    train_predictors = train_predictors,
    train_outcome = train_outcome,
    test_predictors = test_predictors,
    test_outcome = test_outcome,
    Seed = Seed,
    primary = primary
  )
  
  
# extract class specific metrics (e.g. sens, spec)
  train_CM = results$trainCM
  test_CM = results$testCM
  
  train_class_data = train_CM$byClass %>% 
    as.data.frame() %>%  
    mutate(split = "train")
  
  class_data = test_CM$byClass %>%  
    as.data.frame() %>% 
  mutate(split = "test") %>%  
    bind_rows(train_class_data) %>% 
  rownames_to_column(var = "class") %>%  
    separate(class, into = c(NA, "class"), sep = " ") %>% 
    separate(class, into = c("class", NA)) %>% 
    remove_rownames() 


# calculate weighted average from class specific data 
  train_CM_tab = train_CM$table
  test_CM_tab = test_CM$table
  
   summary_class_data =  weighted_av(class_data,train_CM_tab,test_CM_tab )
  
 # extract overall accuracy and kappa 
  
  train_performance = train_CM$overall %>% 
  as.data.frame() %>%  
  mutate(split = "train") %>%  
  rownames_to_column(var = "metric") %>%  
  filter(metric == "Accuracy" | metric == "Kappa")
  
  performance_data = test_CM$overall %>% 
    as.data.frame() %>%  
    mutate(split = "test") %>%  
    rownames_to_column(var = "metric") %>%  
    filter(metric == "Accuracy" | metric == "Kappa") %>%  
    bind_rows(train_performance) %>% 
    pivot_wider(id_cols = split, names_from = metric, values_from = '.') %>% 
    left_join(summary_class_data) %>% 
    pivot_longer(cols = -split, names_to = "metric")
 

  out = list(performance_data)
  
  return(out)
}
