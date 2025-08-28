set.seed(123)
train_index <- sample(nrow(cleandata), 0.7 * nrow(cleandata))
train_freq <- cleandata[train_index,]
test_freq <- cleandata[-train_index,]

train_severity <- train_freq[train_freq$numclaims > 0, ]
test_severity <- test_freq[test_freq$numclaims > 0, ]


############################################################
#----------------------- baseline (glm) --------------------------#
############################################################

#----------------------- default (dummy encoding) --------------------------
freqModel <- glm(numclaims ~  gender + veh_body + area + veh_age + agecat , data = train_freq, family = poisson(link = "log"), offset = log(exposure))
seveModel <- glm(I(claimcst0 / numclaims) ~ gender + veh_body + area + veh_age + agecat, data = train_severity, Gamma(link = "log"), weights = numclaims)

summary(freqModel)   # aic 24286
summary(seveModel)   # aic 58881

actual_freq <- test_severity$numclaims / test_severity$exposure
actual_severity <- test_severity$claimcst0 / test_severity$numclaims
pred_freq <- predict(freqModel, newdata = test_severity, type = "response")
pred_severity <- predict(seveModel, newdata = test_severity, type = "response")

rmse_freq <- sqrt(mean((actual_freq - pred_freq)^2))
rmse_severity <- sqrt(mean((actual_severity - pred_severity)^2))
rmse_freq  #7.663602
rmse_severity  #3291.167

# premium
actual_pure_premium <- actual_freq * actual_severity
pred_pure_premium <- pred_freq * pred_severity

mse_pre <- mean((actual_pure_premium - pred_pure_premium)^2)
rmse_pre <- sqrt(mse_pre)
rmse_pre    #28185.93


#----------------------- target encoding --------------------------
#####target encode gender
count_by_gender<-as.data.frame(table(cleandata$gender))
colnames(count_by_gender) <- c("gender", "count")
count_by_gender$prob<-count_by_gender$count/67566
count_by_gender
cleandata$genderT<-cleandata$gender
cleandata$genderT <- as.character(cleandata$genderT)
cleandata$genderT<-replace(cleandata$genderT,cleandata$genderT=="F",count_by_gender[1,3])
cleandata$genderT<-replace(cleandata$genderT,cleandata$genderT=="M",count_by_gender[2,3])

#####encode veh_body
count_by_veh_body <- as.data.frame(table(cleandata$veh_body))
colnames(count_by_veh_body) <- c("veh_body", "count")

smoothing<-7
trust<-2
count_by_veh_body$weight <- 1 / (1 + exp(-(count_by_veh_body$count - trust) / smoothing))
weight <- count_by_veh_body$weight
weight

mean_encoding <- tapply(cleandata$numclaims, cleandata$veh_body, mean, na.rm = TRUE)
mean_encoding
count_by_veh_body$mean_encoding<-mean_encoding
cleandata$veh_body_mean_encoded <- mean_encoding[cleandata$veh_body]
count_by_veh_body$finalEncoded<-count_by_veh_body$weight*count_by_veh_body$mean_encoding

cleandata$body<-cleandata$veh_body
cleandata$body <- as.character(cleandata$body)
cleandata$body<-replace(cleandata$body,cleandata$body=="COUPE",count_by_veh_body[1,5])
cleandata$body<-replace(cleandata$body,cleandata$body=="HBACK",count_by_veh_body[2,5])
cleandata$body<-replace(cleandata$body,cleandata$body=="HDTOP",count_by_veh_body[3,5])
cleandata$body<-replace(cleandata$body,cleandata$body=="MIBUS",count_by_veh_body[4,5])
cleandata$body<-replace(cleandata$body,cleandata$body=="PANVN",count_by_veh_body[5,5])
cleandata$body<-replace(cleandata$body,cleandata$body=="SEDAN",count_by_veh_body[6,5])
cleandata$body<-replace(cleandata$body,cleandata$body=="STNWG",count_by_veh_body[7,5])
cleandata$body<-replace(cleandata$body,cleandata$body=="TRUCK",count_by_veh_body[8,5])
cleandata$body<-replace(cleandata$body,cleandata$body=="UTE",count_by_veh_body[9,5])

#####encode veh_age
count_by_veh_age<-as.data.frame(table(cleandata$veh_age))
colnames(count_by_veh_age) <- c("veh_age", "count")
count_by_veh_age$prob<-count_by_veh_age$count/67566
count_by_veh_age
cleandata$veh_ageT<-cleandata$veh_age
cleandata$veh_ageT <- as.character(cleandata$veh_ageT)
cleandata$veh_ageT<-replace(cleandata$genderT,cleandata$genderT=="1",count_by_veh_age[1,3])
cleandata$veh_ageT<-replace(cleandata$genderT,cleandata$genderT=="2",count_by_veh_age[2,3])
cleandata$veh_ageT<-replace(cleandata$genderT,cleandata$genderT=="3",count_by_veh_age[3,3])
cleandata$veh_ageT<-replace(cleandata$genderT,cleandata$genderT=="4",count_by_veh_age[4,3])


#####encode area

count_by_area<-as.data.frame(table(cleandata$area))
colnames(count_by_area) <- c("area", "count")
count_by_area$prob<-count_by_area$count/67566
count_by_area
cleandata$areaT<-cleandata$area
cleandata$areaT <- as.character(cleandata$areaT)
cleandata$areaT<-replace(cleandata$areaT,cleandata$areaT=="A",count_by_area[1,3])
cleandata$areaT<-replace(cleandata$areaT,cleandata$areaT=="B",count_by_area[2,3])
cleandata$areaT<-replace(cleandata$areaT,cleandata$areaT=="C",count_by_area[3,3])
cleandata$areaT<-replace(cleandata$areaT,cleandata$areaT=="D",count_by_area[4,3])
cleandata$areaT<-replace(cleandata$areaT,cleandata$areaT=="E",count_by_area[5,3])
cleandata$areaT<-replace(cleandata$areaT,cleandata$areaT=="F",count_by_area[6,3])

#####encode agecat

count_by_agecat<-as.data.frame(table(cleandata$agecat))
colnames(count_by_agecat) <- c("agecat", "count")
count_by_agecat$prob<-count_by_agecat$count/67566
count_by_agecat
cleandata$agecatT<-cleandata$agecat
cleandata$agecatT <- as.character(cleandata$agecatT)
cleandata$agecatT<-replace(cleandata$agecatT,cleandata$agecatT=="1",count_by_area[1,3])
cleandata$agecatT<-replace(cleandata$agecatT,cleandata$agecatT=="2",count_by_area[2,3])
cleandata$agecatT<-replace(cleandata$agecatT,cleandata$agecatT=="3",count_by_area[3,3])
cleandata$agecatT<-replace(cleandata$agecatT,cleandata$agecatT=="4",count_by_area[4,3])
cleandata$agecatT<-replace(cleandata$agecatT,cleandata$agecatT=="5",count_by_area[5,3])
cleandata$agecatT<-replace(cleandata$agecatT,cleandata$agecatT=="6",count_by_area[6,3])


set.seed(123)
train_index <- sample(nrow(cleandata), 0.7 * nrow(cleandata))
train_freq <- cleandata[train_index,]
test_freq <- cleandata[-train_index,]

train_severity <- train_freq[train_freq$numclaims > 0, ]
test_severity <- test_freq[test_freq$numclaims > 0, ]

freqModel <- glm(numclaims ~  genderT + body + areaT + veh_ageT + agecatT , data = train_freq, family = poisson(link = "log"), offset = log(exposure))
seveModel <- glm(I(claimcst0 / numclaims) ~ genderT + body + areaT + veh_ageT + agecatT, data = train_severity, Gamma(link = "log"), weights = numclaims)

summary(freqModel)   # 24306
summary(seveModel)   # 58895

actual_freq <- test_severity$numclaims / test_severity$exposure
actual_severity <- test_severity$claimcst0 / test_severity$numclaims
pred_freq <- predict(freqModel, newdata = test_severity, type = "response")
pred_severity <- predict(seveModel, newdata = test_severity, type = "response")

rmse_freq <- sqrt(mean((actual_freq - pred_freq)^2))
rmse_severity <- sqrt(mean((actual_severity - pred_severity)^2))
rmse_freq  # 7.663663
rmse_severity  # 3285.02

actual_pure_premium <- actual_freq * actual_severity
pred_pure_premium <- pred_freq * pred_severity

mse_pre <- mean((actual_pure_premium - pred_pure_premium)^2)
rmse_pre <- sqrt(mse_pre) 

mse_pre
rmse_pre  # 28185.92


#----------------------- entity embedding --------------------------

library(data.table)
library(keras)
library(ggplot2)

#### veh_body

dataCar = as.data.table(cleandata)
dataCar[, LossRatio := claimcst0 / exposure]
dataCar[, LossRatioScaled := scale(LossRatio)]
dataCar[, veh_body := as.factor(veh_body)]
dataCar[, VehBodyN := as.numeric(veh_body)]

embedding_size <- 3
model <- keras_model_sequential()
model %>% layer_embedding(input_dim = length(unique(dataCar$VehBodyN)) + 1,
                          output_dim = embedding_size, input_length = 1, name = "embedding") %>%
  layer_flatten()  %>%
  layer_dense(units=40, activation = "relu") %>%
  layer_dense(units=10, activation = "relu") %>%
  layer_dense(units=1)
model %>%
  compile(loss = "mse", optimizer = "sgd", metric="accuracy")
hist <- model %>% fit(x = as.matrix(dataCar$VehBodyN), y = as.matrix(dataCar$LossRatioScaled), epochs = 50, 
                      batch_size = floor(0.25 * nrow(dataCar)))

# Extract entity embeddings from the "embedding" layer
layer <- get_layer(model, "embedding")
embeddings <- data.frame(layer$get_weights()[[1]])
embeddings$name <- c("none", levels(dataCar$veh_body))

# Match the embeddings to the original data
embeddings <- embeddings[match(dataCar$veh_body, embeddings$name),]

# Visualize entity embeddings
ggplot(embeddings, aes(X1, X2, color = name)) + geom_point() + geom_text(aes(label = name), hjust = 0, vjust = 0) +
  theme_bw() + xlab("Embedding Dimension 1") + ylab("Embedding Dimension 2")

##### veh_age

dataCar = as.data.table(cleandata)
dataCar[, LossRatio := claimcst0 / exposure]
dataCar[, LossRatioScaled := scale(LossRatio)]
dataCar[, veh_age := as.factor(veh_age)]
dataCar[, VehAgeN := as.numeric(veh_age)]

embedding_size <- 3
model <- keras_model_sequential()
model %>% layer_embedding(input_dim = length(unique(dataCar$VehAgeN)) + 1,
                          output_dim = embedding_size, input_length = 1, name = "embedding") %>%
  layer_flatten()  %>%
  layer_dense(units=40, activation = "relu") %>%
  layer_dense(units=10, activation = "relu") %>%
  layer_dense(units=1)
model %>%
  compile(loss = "mse", optimizer = "sgd", metric="accuracy")
hist <- model %>% fit(x = as.matrix(dataCar$VehAgeN), y = as.matrix(dataCar$LossRatioScaled), epochs = 50, 
                      batch_size = floor(0.25 * nrow(dataCar)))

# Extract entity embeddings from the "embedding" layer
layer <- get_layer(model, "embedding")
embeddings_vehage <- data.frame(layer$get_weights()[[1]])
embeddings_vehage$name <- c("none", levels(dataCar$veh_age))

# Match the embeddings to the original data
embeddings_vehage <- embeddings_vehage[match(dataCar$veh_age, embeddings_vehage$name),]

# Visualize entity embeddings
ggplot(embeddings_vehage, aes(X1, X2, color = name)) + geom_point() + geom_text(aes(label = name), hjust = 0, vjust = 0) +
  theme_bw() + xlab("Embedding Dimension 1") + ylab("Embedding Dimension 2")

##### area

dataCar = as.data.table(cleandata)
dataCar[, LossRatio := claimcst0 / exposure]
dataCar[, LossRatioScaled := scale(LossRatio)]
dataCar[, area := as.factor(area)]
dataCar[, areaN := as.numeric(area)]

embedding_size <- 3
model <- keras_model_sequential()
model %>% layer_embedding(input_dim = length(unique(dataCar$areaN)) + 1,
                          output_dim = embedding_size, input_length = 1, name = "embedding") %>%
  layer_flatten()  %>%
  layer_dense(units=40, activation = "relu") %>%
  layer_dense(units=10, activation = "relu") %>%
  layer_dense(units=1)
model %>%
  compile(loss = "mse", optimizer = "sgd", metric="accuracy")
hist <- model %>% fit(x = as.matrix(dataCar$areaN), y = as.matrix(dataCar$LossRatioScaled), epochs = 50, 
                      batch_size = floor(0.25 * nrow(dataCar)))

# Extract entity embeddings from the "embedding" layer
layer <- get_layer(model, "embedding")
embeddings_area <- data.frame(layer$get_weights()[[1]])
embeddings_area$name <- c("none", levels(dataCar$area))

# Match the embeddings to the original data
embeddings_area <- embeddings_area[match(dataCar$area, embeddings_area$name),]

# Visualize entity embeddings
ggplot(embeddings_area, aes(X1, X2, color = name)) + geom_point() + geom_text(aes(label = name), hjust = 0, vjust = 0) +
  theme_bw() + xlab("Embedding Dimension 1") + ylab("Embedding Dimension 2")


#### agecat

dataCar = as.data.table(cleandata)
dataCar[, LossRatio := claimcst0 / exposure]
dataCar[, LossRatioScaled := scale(LossRatio)]
dataCar[, agecat := as.factor(agecat)]
dataCar[, agecatN := as.numeric(agecat)]

embedding_size <- 3
model <- keras_model_sequential()
model %>% layer_embedding(input_dim = length(unique(dataCar$agecatN)) + 1,
                          output_dim = embedding_size, input_length = 1, name = "embedding") %>%
  layer_flatten()  %>%
  layer_dense(units=40, activation = "relu") %>%
  layer_dense(units=10, activation = "relu") %>%
  layer_dense(units=1)
model %>%
  compile(loss = "mse", optimizer = "sgd", metric="accuracy")
hist <- model %>% fit(x = as.matrix(dataCar$agecatN), y = as.matrix(dataCar$LossRatioScaled), epochs = 50, 
                      batch_size = floor(0.25 * nrow(dataCar)))

# Extract entity embeddings from the "embedding" layer
layer <- get_layer(model, "embedding")
embeddings_agecat <- data.frame(layer$get_weights()[[1]])
embeddings_agecat$name <- c("none", levels(dataCar$agecat))

# Match the embeddings to the original data
embeddings_agecat <- embeddings_agecat[match(dataCar$agecat, embeddings_agecat$name),]

# Visualize entity embeddings
ggplot(embeddings_agecat, aes(X1, X2, color = name)) + geom_point() + geom_text(aes(label = name), hjust = 0, vjust = 0) +
  theme_bw() + xlab("Embedding Dimension 1") + ylab("Embedding Dimension 2")



cleandata$X1 <- embeddings$X1
cleandata$X2 <- embeddings$X2
cleandata$X3 <- embeddings$X3
cleandata$veh_age1 <- embeddings_vehage$X1
cleandata$veh_age2 <- embeddings_vehage$X2
cleandata$veh_age3 <- embeddings_vehage$X3
cleandata$area1 <- embeddings_area$X1
cleandata$area2 <- embeddings_area$X2
cleandata$area3 <- embeddings_area$X3
cleandata$agecat1 <- embeddings_agecat$X1
cleandata$agecat2 <- embeddings_agecat$X2
cleandata$agecat3 <- embeddings_agecat$X3

cleandata$numclaims <- as.numeric(as.character(cleandata$numclaims))

set.seed(123)
train_index <- sample(nrow(cleandata), 0.7 * nrow(cleandata))
train_freq <- cleandata[train_index,]
test_freq <- cleandata[-train_index,]

train_severity <- train_freq[train_freq$numclaims > 0, ]
test_severity <- test_freq[test_freq$numclaims > 0, ]

glm_freq <- glm(numclaims ~ gender + area + veh_age + agecat+ X1 + X2 + X3 + veh_age1 + veh_age2 + veh_age3 + area1 + area2 + area3 + agecat1 + agecat2 + agecat3, data = train_freq,family = poisson(link = "log"),
                offset = log(exposure))

glm_sev <- glm(I(claimcst0 / numclaims) ~ gender + area + veh_age + agecat + X1 + X2 + X3 + veh_age1 + veh_age2 + veh_age3 + area1 + area2 + area3 + agecat1 + agecat2 + agecat3, 
                data = train_severity, family = Gamma(link = "log"), weights = numclaims)

actual_freq <- test_severity$numclaims / test_severity$exposure
actual_severity <- test_severity$claimcst0 / test_severity$numclaims
pred_freq <- predict(glm_freq, newdata = test_severity, type = "response")
pred_severity <- predict(glm_sev, newdata = test_severity, type = "response")

rmse_freq <- sqrt(mean((actual_freq - pred_freq)^2))
rmse_severity <- sqrt(mean((actual_severity - pred_severity)^2))
rmse_freq  # 7.66362086295246
rmse_severity # 3289.60042895351

actual_pure_premium <- actual_freq * actual_severity
pred_pure_premium <- pred_freq * pred_severity

mse_pre <- mean((actual_pure_premium - pred_pure_premium)^2)
rmse_pre <- sqrt(mse_pre) 
rmse_pre # 28186.0775000677
