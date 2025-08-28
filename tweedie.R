#------------------ dummy encoding --------------------#

library(tweedie)
library(cplm)

tweedie_model <- cpglm(
  claimcst0 ~ gender + veh_body + area + veh_age + agecat,
  data = train_freq,
  link = "log",
  weights = exposure  
)

summary(tweedie_model)
tweedie_model$p

pred_cplm <- predict(tweedie_model, newdata = test_freq, type = "response")

actual_cost <- test_freq$claimcst0 / test_freq$exposure
rmse_cplm <- sqrt(mean((actual_cost - pred_cplm)^2))
rmse_cplm



#------------------ target encoding --------------------#

tweedie_model <- cpglm(
  claimcst0 ~ genderT + body + areaT + veh_ageT + agecatT,
  data = train_freq,
  link = "log",
  weights = exposure  
)

summary(tweedie_model)
tweedie_model$p

pred_cplm <- predict(tweedie_model, newdata = test_freq, type = "response")

actual_cost <- test_freq$claimcst0 / test_freq$exposure
rmse_cplm <- sqrt(mean((actual_cost - pred_cplm)^2))
rmse_cplm




#------------------ entity embedding --------------------#

tweedie_model <- cpglm(
  claimcst0 ~ gender + X1 + X2 + X3 + veh_age1 + veh_age2 + veh_age3 + area1 + area2 + area3 + agecat1 + agecat2 + agecat3,
  data = train_freq,
  link = "log",
  weights = exposure
)

summary(tweedie_model)
tweedie_model$p

pred_cplm <- predict(tweedie_model, newdata = test_freq, type = "response")

actual_cost <- test_freq$claimcst0 / test_freq$exposure
rmse_cplm <- sqrt(mean((actual_cost - pred_cplm)^2))
rmse_cplm
