set.seed(123)
train_index <- sample(nrow(cleandata), 0.7 * nrow(cleandata))
train_freq <- cleandata[train_index,]
test_freq <- cleandata[-train_index,]

train_severity <- train_freq[train_freq$numclaims > 0, ]
test_severity <- test_freq[test_freq$numclaims > 0, ]


############################################################
#----------------------- baseline --------------------------#
############################################################

#----------------------- glm --------------------------
freqModel <- glm(numclaims ~  gender + veh_body + area + veh_age + agecat , data = train_freq, family = poisson(link = "log"), offset = log(exposure))
seveModel <- glm(I(claimcst0 / numclaims) ~ gender + veh_body + area + veh_age + agecat, data = train_severity, Gamma(link = "log"), weights = numclaims)

summary(freqModel)   # aic 24286
summary(seveModel)   # aic 58881

actual_freq <- test_severity$numclaims / test_severity$exposure
actual_severity <- test_severity$claimcst0 / test_severity$numclaims
pred_freq <- predict(freqModel, newdata = test_severity, type = "response")
pred_severity <- predict(seveModel, newdata = test_severity, type = "response")

actual_pure_premium <- actual_freq * actual_severity
pred_pure_premium <- pred_freq * pred_severity

mse_pre <- mean((actual_pure_premium - pred_pure_premium)^2)
rmse_pre <- sqrt(mse_pre)
rmse_pre    #28185.93
