##################################################
#  Author:                                       #
#  Nerea Luna Picón               NIA: 100330725 #
##################################################

# Set the path 
# wd = getwd()
# setwd(wd)


###################### INSTALLING PACKAGES ######################

install.packages(c("car", "corrplot", "FactoMineR", "factoextra", "glmnet"))

########################## READING DATA ##########################
if (!file.exists("machine_clean.csv")) {
  
  # Cleaning of the original data:
  
  # Read the original .data file:
  machine = read.table("machine.data", header = FALSE, sep=",", fileEncoding="UTF-8")
  attach(machine)
  names(machine)
  
  # Add header to the data:
  colnames(machine) = c("vendor_name", "model_name", "MYCT", "MMIN",
                        "MMAX", "CACH", "CHMIN", "CHMAX", "PRP", "ERP")
  names(machine)
  
  # Removing the following variables:
  machine$vendor_name <- NULL # irrelevant
  machine$model_name <- NULL # irrelevant
  machine$ERP <- NULL # estimated (predicted) values in the original article
  
  names(machine)
  
  # Create new csv file with cleaned data
  write.csv(machine, row.names=FALSE, "machine_clean.csv")
  
} else {
  
  # Read the cleaned csv file:
  machine = read.csv("machine_clean.csv",sep = ",", dec = ".", strip.white=TRUE)
  attach(machine)
  names(machine)
  nrow(machine) # 209
  
  
  # Removing some outliers (its standarized residual values in absolute value were greater than 3)
  outliers = c(10,32,199,200)
  machine <- machine[-outliers, ]
  nrow(machine) # 205
  
  str(machine)
  # Normalizing the data just to find a better model
  mach_norm <- as.data.frame(apply(machine[, 1:7], 2, function(x) (x - min(x))/(max(x)-min(x))))
  str(mach_norm)
  
}

# Response variable: "PRP" (Published Relative Performance) of computers

####################### PREDICTIVE MODELING #######################

## ---- Correlation matrix -----------------------------------------

# Graphical - pairwise relations with linear and "smooth" regressions
# We performed this graphical study at the beginning since we wanted to assure beforehand that 
# the data was consistent and existed some correlations among the response variable and the predictors

library(car)
scatterplotMatrix(mach_norm, col = 1, regLine = list(col = 2),
                  smooth = list(col.smooth = 4, col.spread = 4))

# We can observe that there is a positive correlation between each of the predictors and the
# response (' PRP' ) except in one case, pair ' MYCT' and ' PRP ,' in which there is a negative
# correlation.
# These results were expected. For instance, the higher the ' MYCT' the lower the performance.


# Obtaining a plot of the correlation matrix
# (all the variables are quantitative)
R.mach_norm.X.quan <- cor(mach_norm)

library("corrplot")
corrplot(R.mach_norm.X.quan)
corrplot(R.mach_norm.X.quan, order="hclust") # hierarchical clustering



## ---- Fitting Linear models -----------------------------------------

# These models were initially built with the original data ('machine'). However, after a long process
# of looking for the best one, I realized that normalizing the data gave me better results.
# This is why in these cases 'machine' is used rather than 'mach_norm'


# Besides, say that these first 7 models were just built for taking a look at our data behaviour, 
# but later on, we will formally conclude (stepAIC and some data transformations) which model is better.

## ---- * LINEAR MODEL 1 -> Predicting PRP with MMAX ------------------
modMachineMMAX <- lm(sqrt(PRP) ~ MMAX, data = machine)  # better with sqrt

# Summary of the model
summodMachineMMAX <- summary(modMachineMMAX) # Multiple R-squared: 0.7454
# Adjusted R-squared:  0.7868 (just for comparing models)
summodMachineMMAX
# Both intercept and predictor are highly significant (***) -> we can reject the null hypothesis and conclude
# there exist a relationship between them

# Estimation of sigma ("Residual standard error")
summodMachineMMAX$sigma # 2.315097

summodMachineMMAX$r.squared # R^2 = 0.745429

# Bayesian Information Criterion 
BIC(modMachineMMAX) # 939.8992

# Akaike Information Criterion
AIC(modMachineMMAX) # 929.9302



## ---- * LINEAR MODEL 2 -> Predicting PRP with MMIN ------------------
modMachineMMIN <- lm(PRP ~ MMIN, data = machine) # better without sqrt/log functions...

# Summary of the model
summodMachineMMIN <- summary(modMachineMMIN) # Multiple R-squared: 0.7384 
# Adjusted R-squared:  0.7372
summodMachineMMIN
# The predictor is highly significant (***) -> we can reject the null hypothesis and conclude
# there exist a relationship MMIN and the response PRP

# Estimation of sigma ("Residual standard error")
summodMachineMMIN$sigma # 56.0561

summodMachineMMIN$r.squared # R^2 = 0.7384441

BIC(modMachineMMIN) # 2246.529
AIC(modMachineMMIN) # 2236.56



## ---- * LINEAR MODEL 3 -> Predicting PRP with MYCT ------------------
modMachineMYCT <- lm(log(PRP) ~ MYCT, data = machine)

# Summary of the model
summodMachineMYCT <- summary(modMachineMYCT) # Multiple R-squared: 0.2884
# Adjusted R-squared:  0.2849
summodMachineMYCT
# Both the intercept and the predictor highly significant (***) -> we can reject the null hypothesis and conclude
# there exist a relationship between them

# Estimation of sigma ("Residual standard error")
summodMachineMYCT$sigma # 0.8346436

summodMachineMYCT$r.squared # R^2 = 0.2883709

BIC(modMachineMYCT) # 521.6163
AIC(modMachineMYCT) # 511.6473



## ---- * LINEAR MODEL 4 -> Predicting PRP with CACH ------------------
modMachineCACH <- lm(sqrt(PRP) ~ CACH, data = machine)

# Summary of the model
summodMachineCACH <- summary(modMachineCACH) # Multiple R-squared: 0.5039
# Adjusted R-squared:  0.5014
summodMachineCACH
# Both the intercept and the predictor highly significant (***) -> we can reject the null hypothesis and conclude
# there exist a relationship between them

# Estimation of sigma ("Residual standard error")
summodMachineCACH$sigma # 3.231892

summodMachineCACH$r.squared # R^2 = 0.503883

BIC(modMachineCACH) # 1076.682
AIC(modMachineCACH) # 1066.713



## ----  * LINEAR MODEL 5 -> Predicting PRP with CHMIN ------------------
modMachineCHMIN <- lm(PRP ~ CHMIN, data = machine)

# Summary of the model
summodMachineCHMIN <- summary(modMachineCHMIN) # Multiple R-squared: 0.4167
# Adjusted R-squared:  0.4139
summodMachineCHMIN
# Both the intercept and the predictor highly significant (***) -> we can reject the null hypothesis and conclude
# there exist a relationship between them

# Estimation of sigma ("Residual standard error")
summodMachineCHMIN$sigma # 83.70845

summodMachineCHMIN$r.squared # R^2 = 0.4167466

BIC(modMachineCHMIN) # 2410.933
AIC(modMachineCHMIN) # 2400.964



## ----  * LINEAR MODEL 6 -> Predicting PRP with CHMAX ------------------
modMachineCHMAX <- lm(log(PRP) ~ CHMAX, data = machine)

# Summary of the model
summodMachineCHMAX <- summary(modMachineCHMAX) # Multiple R-squared: 0.1821
# Adjusted R-squared:  0.178
summodMachineCHMAX
# Both the intercept and the predictor highly significant (***) -> we can reject the null hypothesis and conclude
# there exist a relationship between them

# Estimation of sigma ("Residual standard error")
summodMachineCHMAX$sigma # 0.8948158

summodMachineCHMAX$r.squared # R^2 = 0.1820648

BIC(modMachineCHMAX) # 550.1577
AIC(modMachineCHMAX) # 540.1887


#########################################################################
## ----  * LINEAR MODEL 7 -> Predicting PRP with all the predictors ------
#########################################################################

# Now, we will predict PRP as a function of all the predictors to see
# if we can improve the previous results (which in general were quite weak)

modMachine <- lm(sqrt(PRP) ~., data = machine) 

# Summary of the model (assumptions were 'better' verified by applying the sqrt to the response)
summodMachine <- summary(modMachine) # Multiple R-squared: 0.8943 (sqrt) 
# Adjusted R-squared:  0.8911
summodMachine

par(mfrow=c(2,2))
plot(modMachine)
# Here again, in the majority of the predictors and the intercept we get very low p-values,
# so this will lead us continue the study assuring there would be some relationship between
# some of the variables in the data set 

# Estimation of sigma ("Residual standard error")
summodMachine$sigma # 1.510388

summodMachine$r.squared  # R^2 = 0.8943142 
# in fact we have improved it --> BEWARE! It may be because we have increased p (the number of predictors):

summodMachine$adj.r.squared  # Adjusted R^2 = 0.8911116
# quite similar to R^2

BIC(modMachine) # 786.2968
AIC(modMachine) # 759.7127



# Comparing the models. Values of Intercept and SE are obtained
library(car)
compareCoefs(modMachineMMAX, modMachineMMIN, modMachineMYCT, modMachineCACH, 
             modMachineCHMIN, modMachineCHMAX, modMachine)


# The model with less SE in the intercept is Model 3 (prediction of PRP with MYCT).
# The model with less SE in the set of predictors is however Model 1 (prediction of PRP with MMAX).


# In this case, 0 value does not belong to the CI, so MMAX is significant for us to predict
confint(modMachineMMAX)

# In this last model, by looking at CI ranges, we can observe that only the 0 value does not belong 
# to the interval for coefficients CHMAX. Hence, that predictor would not be significant for the model
confint(modMachine)

# Confidence intervals at other levels (let us check if again CHMAX is not significant)
confint(modMachine, level = 0.90)
confint(modMachine, level = 0.99)
# We can take a look at the CI ranges obtained by changing the confidence levels. As long as the CI gets larger,
# we increase the precision when estimating the coefficients but also the error commited.
# We have checked that still CHMAX define a CI where the 0 values is not included, so we definitely
# can say that predictor CHMAX is not significant (if we take a look again at the inital scatterplot, we can see
# that CHMAX variable is the one presented with less correlation with respect to the PRP response variable)



############################# BIC - AIC (STEPAIC) ############################# 
# Once taken a look to those initial models, we make use of the stepAIC function for inspecting
# much more combinations than before

# With BIC
# We take the model with all predictors (modMachine model) since 'stepAIC' is supposed to give us the 'best' combination
modBIC <- MASS::stepAIC(modMachine, k = log(nrow(wine)))
summary(modBIC)

# With AIC
modAIC <- MASS::stepAIC(modMachine, k = 2)
summary(modAIC)


# Different search directions 
modAICFor <- MASS::stepAIC(modMachine, trace = 0, direction = "forward") # simplest model
modAICBack <- MASS::stepAIC(modMachine, trace = 0, direction = "backward") # full model
modAICFor
modAICBack

# Our idea was keeping the best model given by 'stepAIC' and checked with it the four 
# assumptions, but as can be observed in the results of that model (Linear Model 7.1), 
# not all assumptions were verified.


######################################################################################
## ----  * LINEAR MODEL 7.1 -> Predicting PRP with all the predictors (- CHMAX) ------
######################################################################################

# Best model given by 'stepAIC' (we have no 'NA' values)
# (Unfortunately, it does not verify the four assumptions)
modMachine_1 <- lm(sqrt(PRP) ~ MYCT + MMIN + MMAX + CACH + CHMIN, data = machine) 

# Summary of the model
summodMachine <- summary(modMachine_1) # Multiple R-squared: 0.8935
# Adjusted R-squared: 0.8908 
summodMachine

# Same model but with data normalized ('mach_norm' instead of 'machine')
# Here, homoscedasticity and independence of errors were neither satisfied
modMachine_1 <- lm(sqrt(PRP) ~ MYCT + MMIN + MMAX + CACH + CHMIN, data = mach_norm) 

# Summary of the model
summodMachine <- summary(modMachine_1) # Multiple R-squared: 0.8864
# Adjusted R-squared: 0.8836 
summodMachine
# p = 0.00095096 (Breusch test)  - p = 0 (Durbin test)

# At this point, each time playing with less alternatives to test, we decided to perform some 
# data transformations in the response variable, predictors (or even to both of them at the same time),
# since we did not found any relevant model with this approach.


####################################################################
## ---- * LINEAR MODEL 8  -> Predicting PRP with MMAX and MMIN ----
####################################################################

# We finally (a bit desperated), decided to build a model that used the two most correlated predictors
# according to the correlation matrix shown at the beginning of the script, 
# to see if we could improve almost a little.

modMachine_MMAX_MMIN_sqrt <- lm(sqrt(PRP) ~ MMAX + MMIN, data = machine)
summary(modMachine_MMAX_MMIN_sqrt) # Multiple R-squared:  0.8149 
# Adjusted R-squared:  0.8131
# This model explains 81.49% of the total variability of the data, which is quite a good result
# Besides, all its coefficients are significant as can be observed in the table 
# (But we still needed to prove the four assumptions, so these results were not definitive)


# par(mfrow=c(2,2))
# plot(modMachine_MMAX_MMIN_sqrt)

BIC(modMachine_MMAX_MMIN_sqrt) # 879.9016
AIC(modMachine_MMAX_MMIN_sqrt) # 866.6096


# Specific data for predicting:
new_data_MMAX_MMIN <- data.frame(MMAX =32000, MMIN =8000)

# Prediction of the mean at 95%
predict(modMachine_MMAX_MMIN, newdata = new_data_MMAX_MMIN)  # predicted mean = 345.6558

# Prediction of the mean with different confidence intervals
predict(modMachine_MMAX_MMIN, newdata = new_data_MMAX_MMIN, interval = "confidence") # 95% confidence level
predict(modMachine_MMAX_MMIN, newdata = new_data_MMAX_MMIN, interval = "confidence", level = 0.90)
predict(modMachine_MMAX_MMIN, newdata = new_data_MMAX_MMIN, interval = "confidence", level = 0.99)

# Prediction of the response with 95% confidence interval
# According to the new data used, the 95% prediction interval for the PRP
# of a computer is between this range: [198.7153 - 492.5964]
predict(modMachine_MMAX_MMIN, newdata = new_data_MMAX_MMIN, interval = "prediction", level = 0.95)
# predicted PRP = 345.6558





                                      ####################
                                      # BEST MODEL FOUND #
                                      ####################

# Last try -> NORMALIZING the data
modMachine_MMAX_MMIN_sqrt <- lm(sqrt(PRP) ~ MMAX + MMIN, data = mach_norm)
summary(modMachine_MMAX_MMIN_sqrt) # Adjusted R-squared: 0.8054  --  Multiple R-squared:  0.8073

# Assumptions are tested below, but here it is a summary of them:
# linear OK
# pvalue (Breusch test) = 0.33441 (we then assume homocedasticity) OK
# normality OK
# pvalue (Durbin Watson) = 0.005 (NOT satisfied but we haven't been able to find a better one)
# We will work with this model for the rest of the project even though independence is not satisfied) 

# This model explains 80.73% of the total variability of the data, which quite a good result
# Besides, all its coefficients are significant as can be observed in the summary table 

# BICs (Smaller -> better)
BIC(modMachine_MMAX_MMIN_sqrt) # -413.5547

# AICs (Smaller -> better)
AIC(modMachine_MMAX_MMIN_sqrt) # -426.8467
# Smallest values in comparison with the set of previous tested models, which is good despite of
# the difficulties we were facing for proving the whole set of assumptions






## ---- ASSUMPTIONS of the best linear model ('modMachine_MMAX_MMIN_sqrt') ----------

# (The commented code lines for each assumption refer to those models that finally were not selected)

## ----  * 1) LINEARITY ------ 
# We will plot the residuals (estimated errors) in terms of the fitted values to see the trend of the function
# and check possible linearity of the data


# modMachine is the model that uses all the predictors (not good one)
# plot(modMachine, 1, main="Linearity assumption (sqrt(PRP))")
# We can observe that, in average, there is a trend between the residuals and the estimated responses, 

# Best model according to 'stepAIC1' (not good one)
#plot(modMachine_1, 1, main="Linearity assumption (-CHMAX)")

# Best model (this line was also used for testing the same model but without normalizing the data)
plot(modMachine_MMAX_MMIN_sqrt, 1, main="Linearity assumption (sqrt(PRP))")
# We can see how data follows a quite linear function. Red line takes values close to 0 all along x-axis

# If nonlinearities are observed, it is worth to plot the regression terms of the mode 
par(mfrow = c(2, 3)) # We have 2 predictors
# Regression for each of the predictors, by separate
termplot(modMachine_MMAX_MMIN_sqrt, partial.resid = TRUE, col.res = "black")



## ----  * 2) HOMOSCEDASTICITY ------ 
# We first perform a Scale-Location plot for having some rough idea, but we then applied
# the Breusch Pagan test for identifying evident non constant variances in the data.

# H0 (null hypothesis): data verifies homoscedasticity
# H1 (alternative hypothesis): data verifies hereroskedasticity

# (not good models)
# plot(modMachine, 3, main = "Homoscedasticity assumption")
# plot(modMachine_1, 3, main = "Homoscedasticity assumption (sqrt(PRP))")

# Scale-Location plot (best model)
plot(modMachine_MMAX_MMIN_sqrt, 3, main = "Homoscedasticity assumption (sqrt(PRP))") 


# Breusch-Pagan test (to test the null hypothesis of homoscedasticity)
library(car)

# (not good models)
# car::ncvTest(modMachine) # p = 2.9463e-05 
# car::ncvTest(modMachine_1) 

# Best model (Breusch-Pagan test)
car::ncvTest(modMachine_MMAX_MMIN_sqrt) #  p = 0.33441 -> "We DO NOT REJECT homoscedasticity"
# With Breusch test, after getting a p-value higher than 0.05, we can not reject H0 and consequently,
# do not reject homoscedasticity


## ----  * 3) NORMALITY ------

# QQ-plot (Theoretical Quantile vs. Empirical Quantile)

# (not good models)
# plot(modMachine, 2, main = "Normality assumption")
# plot(modMachine_1, 2, main = "Normality assumption")

# Best model
plot(modMachine_MMAX_MMIN_sqrt, 2, main = "Normality assumption (sqrt(PRP))")

# We can assume normality since the majority of the centered data coincides with the main dashed diagonal
# (even though we have some data around the extremes that does not exactly fit with this line)



# Transformation of non-normal response in a linear model (just trying to improve)

# Optimal lambda for Yeo-Johnson
YJ <- car::powerTransform(modMachine_MMAX_MMIN_sqrt, family = "yjPower")
(lambdaYJ <- YJ$lambda)
##        Y1 
## 0.2820251

# Yeo-Johnson transformation
PRP_Transf <- car::yjPower(U = mach_norm$PRP, lambda = lambdaYJ)
modMachineTransf <- lm(PRP_Transf ~ . - PRP, data = mach_norm)
# modMachineTransf (to check the predictors)
# Comparison for the residuals
par(mfrow = c(1, 2))
plot(modMachine_MMAX_MMIN_sqrt, 2)
plot(modMachineTransf, 2) # Slightly better



## ----  * 4) INDEPENDENCE OF ERRORS ------

# Looking for autocorrelation in the plot

# (not good ones)
# plot(modMachine$residuals, type = "o", main = "Independence of the errors")
# plot(modMachine_1$residuals, type = "o", main = "Independence of the errors (- CHMAX)")
# lag.plot(modMachine_1$residuals, lags = 1, do.lines = FALSE, main = "Independence of the errors - Lagged plot")


# Best model
plot(modMachine_MMAX_MMIN_sqrt$residuals, type = "o", main = "Independence of the errors (sqrt(PRP))")


# By applying the sqrt to the response variable, we have improved the results of this plot 
# (cloud of points is more dispersed now). However, we carried out the Durbin-Watson test 
# to verify our results and unfortunaltely, our p-value was smaller than 0.05 as can be observed below
lag.plot(modMachine_MMAX_MMIN_sqrt$residuals, lags = 1, do.lines = FALSE, main = "Independence of the errors - Lagged plot")


# Durbin-Watson test
# (not good ones)
# car::durbinWatsonTest(modMachine)
# lag Autocorrelation D-W Statistic p-value
# 1       0.3845589      1.202046       0
# Alternative hypothesis: rho != 0
# --> p-value different from 0.05 => "We REJECT independence of errors"

# car::durbinWatsonTest(modMachine_1)


# Best model (Durbin-Watson test)
car::durbinWatsonTest(modMachine_MMAX_MMIN_sqrt) # por qu? var?a el p-value?, aun as? nunca es mayor a 0.05
# lag Autocorrelation D-W Statistic p-value
# 1       0.1593632      1.590404   0.002   # "We REJECT independence of errors" pero al menos no sale 0... (se acerca mas a 0.05...) 
# Alternative hypothesis: rho != 0

# This test has been the key point for assuring or not the compliance of this last assumption. As stated in the report,
# we will continue working with this model even though this assumption has been rejected.
# We also analyzed our data and effectively checked that our data did not follow any kind of
# time-series fashion, so after applying many transformations to our data, we still we did not know
# very well how to fix this issue.






## ----- ANOVA --------------------------------------------------

# This function computes the simplified ANOVA from a linear model
# That is, a decomposition of our data variance (of Y) into:
# SSR: (variation of the regression)
# RSS: (error)
simpleAnova <- function(object, ...) {
  
  # Compute anova table
  tab <- anova(object, ...)
  
  # Obtain number of predictors
  p <- nrow(tab) - 1
  
  # Add predictors row
  predictorsRow <- colSums(tab[1:p, 1:2])
  predictorsRow <- c(predictorsRow, predictorsRow[2] / predictorsRow[1])
  
  # F-quantities
  Fval <- predictorsRow[3] / tab[p + 1, 3]
  pval <- pf(Fval, df1 = p, df2 = tab$Df[p + 1], lower.tail = FALSE)
  predictorsRow <- c(predictorsRow, Fval, pval)
  
  # Simplified table
  tab <- rbind(predictorsRow, tab[p + 1, ])
  row.names(tab)[1] <- "Predictors"
  return(tab)
  
}

# Simplified ANOVA table
simpleAnova(modMachine_MMAX_MMIN_sqrt)
# --> p-value: 2.2e-16 (smaller than 0.05) => F value: 423.23 (larger than 0)
# We REJECT the null hypothesis of no linear dependence of Y on predictors MMAX/MMIN

# R's ANOVA table 
anova(modMachine_MMAX_MMIN_sqrt)
# --> All p-values are smaller than 0.05 (and all F values are larger than 0)
# We REJECT the null hypothesis





## ----- Multicolinearity --------------------------------------------------
# (This section will be developed despite of the last assumption of independence is not verified)

# Original data
## machine = read.csv("machine_clean.csv",sep = ",", dec = ".", strip.white=TRUE)

# Normalized data
## mach_norm <- as.data.frame(apply(machine[, 1:7], 2, function(x) (x - min(x))/(max(x)-min(x))))

# Detecting possible multicolinearity among the predictors 
cor(mach_norm)

# Graphically, we can take a look at the correlation matrix between the predictors
corrplot::corrplot(cor(mach_norm), addCoef.col = "grey")
# By looking at the correlation matrix, we can observe that within the set of predictors, MMIN and MMAX
# are the ones showing more correlation


# modMachine_MMAX_MMIN_sqrt <- lm(sqrt(PRP) ~ MMAX + MMIN, data = mach_norm)
# Variance Inflation Factor (VIF) for each of the estimated betas
car::vif(modMachine_MMAX_MMIN_sqrt)
#     MMAX     MMIN 
#   2.345155 2.345155
# As VIF values for both predictors are not larger than 5 (closest to 1), we can assume there 
# is no multicolinearity among these two predictors

 

## ----- Outliers -----------------------------

# We will explain this outliers section here although we need to say that for trying to get a model
# that satisfied all the assumptions, we needed beforehand to analyze the data points for identifying 
# possible outliers, since we thought the presence of them could be one of the reasons our models 
# did not verify the assumptions (unfortunately this did not solve even the problem)

plot(modMachine_MMAX_MMIN_sqrt, 5)
abline(h=3)
# We can take a look at the graph and identify the distribution of points in the space.



## ----- Leverage points -----------------------------

# Leverage expected value    # 0.01463415
# (p + 1) / n
3 / 205

# Accessing leverage statistics (vector containing the diagonal of the 'hat' matrix)
head(influence(model = modMachine_MMAX_MMIN_sqrt, do.coef = FALSE)$hat)
#           1           2           3           4           5           6 
#      0.007560194 0.026515982 0.026515982 0.026515 982 0.023690168 0.026515982

# Minimum leverage statistic value (1/n)
1/205 #0.004878049

# Having a high leverage if value in i-th position in main matrix diagonal exceeds 0.01463415 (calculated before)
# We can check that all values h_i are in between 1/205 <= h_i <= 1
# Besides, we can conclude that as long as the leverage statistic value increases, that means 
# observations stand far from the rest in x and y-axis, so that point will significantly affect 
# both the intercept and the slope of the regression line.






## ----  PLS  -----------------------------------------------
# Partial Least Squares

# Taking into account the response
library(pls)
modPls <- plsr(PRP ~ ., data = machineRed2, scale = TRUE)

summary(modPls)

# names(modPls)

# PLS scores
head(modPls$scores)

# Also uncorrelated
head(cov(modPls$scores))

# Coefficients 
modPls$coefficients[, , 2]

# Coefficients of the PLS components
lm(formula = PRP ~., data = data.frame("PRP" = mach_norm$PRP, modPls$scores[, 1:3]))

# Prediction
predict(modPls, newdata = machineRed2[1:2, ], ncomp = 6)
#         PRP
#     1 0.3281280
#     2 0.3982994


# Selecting the number of components to retain
modPls2 <- plsr(PRP ~ ., data = machineRed2, scale = TRUE, ncomp = 2)
summary(modPls2)

# Selecting the number of components to retain by Leave-One-Out cross-validation
modPlsCV1 <- plsr(PRP ~ ., data = machineRed2, scale = TRUE,
                  validation = "LOO")
summary(modPlsCV1)

# View cross-validation Mean Squared Error Prediction
validationplot(modPlsCV1, val.type = "MSEP") 

# Selecting the number of components (l) to retain by Leave-One-Out (LOO) cross-validation
modPlsCV10 <- plsr(PRP ~ ., data = machineRed2, scale = TRUE, validation = "CV")
summary(modPlsCV10)
validationplot(modPlsCV10, val.type = "MSEP")



# Create a new dataset with the response + PLS components
machinePLS <- data.frame("PRP" = mach_norm$PRP, cbind(modPls$scores))

# Regression on all principal components
modPLS <- lm(PRP ~ Comp.1 + Comp.2, data = machinePLS)
summary(modPLS) # Predictors clearly significative
# Multiple R-squared:  0.8942,	Adjusted R-squared:  0.8932
car::vif(modPLS) # All VIF values exactly 1, no multicolinearity
