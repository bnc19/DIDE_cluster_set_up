


get_CM = function (model_fit,
                  classifier_name,
                  train_outcome) {
  library(dplyr)
  library(caret)
  
  # calculate PPV and NPV from model predictions and observations
  getPred = function(model_fit,
                     classifier_name,
                     train_outcome) {
    model = model_fit
    
    # RF pred and obs
    
    rfResults = function(model) {
      Pred = model$finalModel$predictions
      Obs = model$trainingData$.outcome
      
      BT = model$bestTune
      row = rownames(BT)
      best = as.data.frame(model$results[row, ])
      
      out = data.frame(Pred, Obs)
      return(list(out, best))
    }
    
    
    # gbm pred and obs
    
    gbmResults =  function(model) {
      BT = model$bestTune
      allPred = model$pred
      bestmodel = filter(
        allPred,
        shrinkage == BT$shrinkage &
          interaction.depth == BT$interaction.depth &
          n.minobsinnode == BT$n.minobsinnode &
          n.trees == BT$n.trees
      )
      
      Pred = (bestmodel$pred)
      Obs = (bestmodel$obs)
      out = data.frame(Pred, Obs)
      
      row = rownames(BT)
      best = as.data.frame(model$results[row, ])
      return(list(out, best))
    }
    
    
    # nn pred and obs
    
    nnResults =  function(model) {
      BT = model$bestTune
      allPred = model$pred
      bestmodel = filter(allPred,
                         size == BT$size &
                           decay == BT$decay &
                           bag == BT$bag)
      
      Pred = (bestmodel$pred)
      Obs = (bestmodel$obs)
      out = data.frame(Pred, Obs)
      
      row = rownames(BT)
      best = as.data.frame(model$results[row, ])
      return(list(out, best))
    }
    
    
    # SVM poly pred and obs
    
    PsvmResults =  function(model) {
      BT = model$bestTune
      allPred = model$pred
      bestmodel = filter(allPred,
                         degree == BT$degree &
                           scale == BT$scale &
                           C == BT$C)
      
      Pred = (bestmodel$pred)
      Obs = (bestmodel$obs)
      out = data.frame(Pred, Obs)
      
      row = rownames(BT)
      best = as.data.frame(model$results[row, ])
      return(list(out, best))
    }
    
    
    # SVM radial pred and obs
    
    RsvmResults =  function(model) {
      BT = model$bestTune
      allPred = model$pred
      bestmodel = filter(allPred,
                         sigma == BT$sigma,
                         C == BT$C)
      
      Pred = (bestmodel$pred)
      Obs = (bestmodel$obs)
      out = data.frame(Pred, Obs)
      
      row = rownames(BT)
      best = as.data.frame(model$results[row, ])
      return(list(out, best))
    }
    
    
    # XGB pred and obs
    
    xgbResults =  function(model) {
      BT = model$bestTune
      allPred = model$pred
      bestmodel = filter(
        allPred,
        nrounds == BT$nrounds,
        max_depth == BT$max_depth,
        eta == BT$eta,
        gamma == BT$gamma,
        colsample_bytree == BT$colsample_bytree,
        min_child_weight == BT$min_child_weight,
        subsample == BT$subsample
      )
      
      
      Pred = (bestmodel$pred)
      Obs = (bestmodel$obs)
      out = data.frame(Pred, Obs)
      
      row = rownames(BT)
      best = as.data.frame(model$results[row, ])
      return(list(out, best))
    }
    
    # mlr pred and obs
    
    mlrResults = function(model) {
      BT = model$bestTune
      allPred = model$pred
      bestmodel = filter(allPred,
                         decay == BT$decay)
      
      
      Pred = (bestmodel$pred)
      Obs = (bestmodel$obs)
      out = data.frame(Pred, Obs)
      
      BT = model$bestTune
      row = rownames(BT)
      best = as.data.frame(model$results[row, ])
      
      return(list(out, best))
    }
    
    # use classifier_name to obtain predicted and observed
    
    PredOb = switch(
      classifier_name,
      rf = rfResults(model_fit),
      gbm = gbmResults (model_fit),
      nnet = nnResults(model_fit),
      svm_poly = PsvmResults(model_fit),
      svm_rad = RsvmResults(model_fit),
      xgboost = xgbResults(model_fit),
      mlr = mlrResults(model_fit)
    )
    
    
    CM =  confusionMatrix(PredOb[[1]]$Pred, PredOb[[1]]$Obs)
    return(CM)
    
  }
  
  
  # create data frame of all results
  CM = getPred(model_fit, classifier_name, train_outcome)
  
  return(CM)
}
