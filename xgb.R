#--------------------dummy encoding--------------------#
library(data.table)
library(xgboost)

feature_cols <- c("gender", "veh_body", "area", "veh_age", "agecat")

y_train_freq <- train_freq$numclaims / train_freq$exposure
y_test_freq <- test_freq$numclaims / test_freq$exposure

X_train_freq <- model.matrix(~ . - 1, data = train_freq[, ..feature_cols])
X_test_freq <- model.matrix(~ . - 1, data = test_freq[, ..feature_cols])

dtrain_freq <- xgb.DMatrix(data = X_train_freq, label = y_train_freq)
dtest_freq <- xgb.DMatrix(data = X_test_freq, label = y_test_freq)

# freq model

params_freq <- list(
  objective = "count:poisson",
  eval_metric = "rmse",
  eta = 0.01,
  max_depth = 4,
  subsample = 0.7,
  colsample_bytree = 0.7
)

xgb_freq_model <- xgb.train(
  params = params_freq,
  data = dtrain_freq,
  nrounds = 1000,
  watchlist = list(train = dtrain_freq, test = dtest_freq),
  early_stopping_rounds = 20,
  verbose = 1
)

# sev model

y_train_sev <- train_severity$claimcst0 / train_severity$numclaims
y_test_sev <- test_severity$claimcst0 / test_severity$numclaims

X_train_sev <- model.matrix(~ . - 1, data = train_severity[, ..feature_cols])
X_test_sev <- model.matrix(~ . - 1, data = test_severity[, ..feature_cols])

dtrain_sev <- xgb.DMatrix(data = X_train_sev, label = y_train_sev)
dtest_sev <- xgb.DMatrix(data = X_test_sev, label = y_test_sev)

params_sev <- list(
  objective = "reg:gamma",
  eval_metric = "rmse",
  eta = 0.01,
  max_depth = 4,
  subsample = 0.7,
  colsample_bytree = 0.7
)

xgb_sev_model <- xgb.train(
  params = params_sev,
  data = dtrain_sev,
  nrounds = 1000,
  watchlist = list(train = dtrain_sev, test = dtest_sev),
  early_stopping_rounds = 20,
  verbose = 1
)


# premium

X_sev_for_freq <- model.matrix(~ . - 1, data = test_severity[, ..feature_cols])
dtest_sev_for_freq <- xgb.DMatrix(data = X_sev_for_freq)

pred_freq_on_sev <- predict(xgb_freq_model, dtest_sev_for_freq)

pred_sev <- predict(xgb_sev_model, dtest_sev)

pred_premium <- pred_freq_on_sev * pred_sev

actual_premium <- test_severity$claimcst0

rmse_premium <- sqrt(mean((pred_premium - actual_premium)^2))
mae_premium <- mean(abs(pred_premium - actual_premium))

cat("\nPremium Evaluation (on severity dataset):\n")
cat("Premium RMSE:", rmse_premium, "\n")
cat("Premium MAE:", mae_premium, "\n")

#--------------------target encoding--------------------#

feature_cols <- c("genderT", "body", "areaT", "veh_ageT", "agecatT")


#--------------------entity embedding--------------------#
feature_cols <- c("gender", "X1", "X2", "X3", "area1", "area2", "area3","veh_age1","veh_age2","veh_age3", "agecat1","agecat2","agecat3")
