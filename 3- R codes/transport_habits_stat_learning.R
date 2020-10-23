# Set the path 
wd = getwd()
setwd(wd)

# We read the data file (166 rows) as a dataframe:
x = read.csv("Transport_habits.csv",sep = ";", dec = ".")
attach(x)
names(x) # 6 variables


########## DESCRIPTIVE ANALYSIS ##########

# Frequency table:
table(GENDER)
table(TRANSPORT_TYPE)
table(PURPOSE)


# Relative frequency table:
n = length(GENDER)
table(GENDER)/n
table(TRANSPORT_TYPE)/n
table(PURPOSE)/n


# Absolute and relative frequency table:
table(TIME.MIN.)
table(DISTANCE.KM.)
n = length(TRANSPORT_TYPE)
table(TIME.MIN.)/n
table(DISTANCE.KM.)/n

# Barplots Qualitatives:
barplot(table(GENDER), col = c("light blue","orange"))
barplot(table(TRANSPORT_TYPE), col= c("dark blue","yellow","dark green"))

# Barplot and boxplot for AGE#
barplot(table(AGE)/n, col= c("light blue"))
barplot(table(AGE), col=c("light blue"))
boxplot(AGE, col=c("light green"))$stats


#HISTOGRAM#
hist(DISTANCE.KM., freq=F,
     col= c("navy blue") )
plot(ecdf(DISTANCE.KM.),
     col= c("light blue","light green","orange"))
hist(TIME.MIN., freq =F,
     col= c("dark blue"))
plot(ecdf(TIME.MIN.),
     col= c("blue","green"," dark orange"))


#BARPLOT TRANSPORT VS GENDER#
table(GENDER, TRANSPORT_TYPE)
barplot(as.matrix(table(GENDER,TRANSPORT_TYPE)), col= c("light blue","orange"))
legend("bottom",inset=0.02,c("Female","Male"),fill=c("light blue","orange"),cex=0.8, text.font = 3)


#BARPLOT GENDER VS PURPOSE#
table(GENDER,PURPOSE)
barplot(as.matrix(table(GENDER,PURPOSE)), col= c("light blue","orange"))
legend("top",inset=0.02,c("Female","Male"),fill=c("light blue","orange"),cex=0.8, text.font = 3)

# DISTANCE vs TRANSPORT
boxplot( DISTANCE.KM.~ PURPOSE, col=c("light blue","yellow","orange","dark green"))$stats
boxplot( TIME.MIN.~ TRANSPORT_TYPE, col=c("light blue","yellow","orange","dark green"))$stats


# Scatter plot of DISTANCE vs TIME (while considering different types of transports)
# We can observe the relation between the time spent going to a place is dependent on the distance traveled
plot(DISTANCE.KM.[TRANSPORT_TYPE=="Private transport"],TIME.MIN.[TRANSPORT_TYPE=="Private transport"],  col= c(1:50) )
plot(DISTANCE.KM.[TRANSPORT_TYPE=="Public transport"],TIME.MIN.[TRANSPORT_TYPE=="Public transport"],  col= c(1:50) )
plot(DISTANCE.KM.[TRANSPORT_TYPE=="Walking"],TIME.MIN.[TRANSPORT_TYPE=="Walking"],  col= c(1:50) )



########## INFERENCE ANALYSIS ##########
####### 1. #######
# Trying to fit a distribution model to fit each of the integer-valued/continuous variables

install.packages("fitdistrplus")
library(fitdistrplus)

# DISTANCE.KM.
hist(DISTANCE.KM.,freq=F)
grid=seq(0.1,50,1)

# Gaussian
fit = fitdist(DISTANCE.KM.,"norm",method="mme")
lines(grid,dnorm(grid,fit$estimate[1],fit$estimate[2]), col= c("light blue"))

# Gamma MLE
fit2=fitdist(DISTANCE.KM.,"gamma",method="mle")
lines(grid,dgamma(grid,fit2$estimate[1],fit2$estimate[2]), col= c("light green"))

# Gamma MME
fit3=fitdist(DISTANCE.KM.,"gamma",method="mme")
lines(grid,dgamma(grid,fit3$estimate[1],fit3$estimate[2]), col= c("black"))

# Exponential
fit4=fitdist(DISTANCE.KM.,"exp",method="mle")
lines(grid,dexp(grid,fit4$estimate[1]), col= c("orange"))
legend("topright",inset=0.03,c("Gaussian","Gamma mle", "Gamma mme", "Exponential"),fill=c("light blue","light green",'black','orange'),cex=0.8, text.font = 3)

# Ecdf
plot(ecdf(DISTANCE.KM.))
lines(grid,pnorm(grid,fit$estimate[1],fit$estimate[2]), col= c("light blue"))
lines(grid,pgamma(grid,fit2$estimate[1],fit2$estimate[2]), col= c("light green"))
lines(grid,pgamma(grid,fit3$estimate[1],fit3$estimate[2]), col= c("black"))
lines(grid,pexp(grid,fit4$estimate[1]), col= c("orange"))
legend("center",inset=0.03,c("Gaussian","Gamma mle", "Gamma mme", "Exponential"),fill=c("light blue","light green",'black','orange'),cex=0.8, text.font = 3)

# Model comparison using AIC (Akaike Criterion) for gamma comparison: MME, MLE 

# Gamma MLE
fit2$aic # 1532.403
# Gamma MME
fit3$aic # 1470.315 (the lower, the better)

# To check parameters
fit$estimate
fit2$estimate
fit3$estimate

# To check min max
summary(DISTANCE.KM.)

# TIME.MIN.
hist(TIME.MIN., freq = F, ylim = c(0,0.027))
grid=seq(4,100,1)

# Gaussian
fit = fitdist(TIME.MIN.,"norm",method="mme")
lines(grid,dnorm(grid,fit$estimate[1],fit$estimate[2]),col= c("orange"))

# Exponential
fit2 = fitdist(TIME.MIN.,"exp",method="mme")
lines(grid,dexp(grid,fit2$estimate[1]),col= c("light blue"))

# Gamma MLE
fit3 = fitdist(TIME.MIN.,"gamma",method="mle")
lines(grid,dgamma(grid,fit3$estimate[1],fit3$estimate[2]),col= c("darkolivegreen4"))

# Gamma MME
fit4 = fitdist(TIME.MIN.,"gamma",method="mme")
lines(grid,dgamma(grid,fit4$estimate[1],fit4$estimate[2]),col=c("coral4"))

legend("topright",inset=0.03,c("Normal","Exponential","Gamma Mle","Gamma Mme"),fill=c("light blue","orange",'darkolivegreen4','coral4'),cex=0.8, text.font = 3)

# LNORM
fit5 = fitdist(log(TIME.MIN.),"lnorm",method="mme")
fit5$estimate
hist(log(TIME.MIN.), freq = F, ylim = c(0,1))
min(log(TIME.MIN.))
max(log(TIME.MIN.))
grid2=seq(1.386,4.61,0.01)
min(TIME.MIN.)
lines(grid2,dlnorm(grid2,fit5$estimate[1],fit5$estimate[2]))

# Ecdf
plot(ecdf(TIME.MIN.))
lines(grid,pnorm(grid,fit$estimate[1],fit$estimate[2]),col=c("light blue"))
lines(grid,pexp(grid,fit2$estimate[1],fit2$estimate[2]),col=c("orange"))
lines(grid,pgamma(grid,fit3$estimate[1],fit3$estimate[2]),col= c("darkolivegreen4"))
lines(grid,pgamma(grid,fit4$estimate[1],fit4$estimate[2]),col=c("coral4"))

legend("right",inset=0.03,c("Normal","Exponential","Gamma Mle","Gamma Mme"),fill=c("light blue","orange",'darkolivegreen4','coral4'),cex=0.8, text.font = 3)

# Model comparison using AIC for gamma comparison MME, MLE 

# Gamma MLE
fit3$aic
# Gamma MME
fit4$aic

# To check parameters
fit2$estimate
fit3$estimate
fit4$estimate

# To check min max
summary(TIME.MIN.)

# AGE
hist(AGE,freq=F)
summary(AGE)
grid=seq(18,71,1)

# Binomial
fitBinom=fitdist(data=AGE, dist="binom", fix.arg=list(size=165), start=list(prob=0.2054734))

lines(grid,dbinom(grid, prob=fitBinom$estimate[1], size=165), col= c("light blue"))

# Poisson
fitPoisson=fitdist(data=AGE, dist="pois")
lines(grid,dpois(grid, lambda=33.90303), col= c("light green"))
legend("right",inset=0.03,c("Binom","Poisson"),fill=c("light blue","light green"),cex=0.8, text.font = 3)
fitPoisson$estimate # 0.2054734
fitBinom$estimate   # 33.90303


####### 2. #######
# Obtaining confidence intervals for the population mean of some variables of interests
t.test(DISTANCE.KM.) # Student's t-test for DISTANCE.KM.
t.test(TIME.MIN.) # Student's t-test for TIME.MIN.
t.test(AGE) # Student's t-test for AGE


####### 3. #######
# Testing some hypothesis for the population mean obtained from a news paper
t.test(TIME.MIN.[TRANSPORT_TYPE=="Public transport"], mu=62, alternative="l")


####### 4. #######
# Testing the independence of two qualitative variables
# Independence test of GENDER and TRANSPORT_TYPE
chisq.test(GENDER, TRANSPORT_TYPE)
chisq.test(GENDER, TRANSPORT_TYPE)$observed
chisq.test(GENDER, TRANSPORT_TYPE)$expected

# Independence test of GENDER and PURPOSE
chisq.test(GENDER,PURPOSE)
chisq.test(GENDER,PURPOSE)$observed
chisq.test(GENDER,PURPOSE)$expected

# Independence test of TRANSPORT_TYPE and PURPOSE
chisq.test(TRANSPORT_TYPE, PURPOSE)
chisq.test(TRANSPORT_TYPE, PURPOSE)$observed
chisq.test(TRANSPORT_TYPE, PURPOSE)$expected


####### 5. #######
# Testing the difference in the mean of two independent groups
# Boxplot TIME.MIN and PURPOSE
Y1 =TIME.MIN.[PURPOSE=="University"]
Y2 =TIME.MIN.[PURPOSE=="Work"]
boxplot(Y1,Y2, names = c("University", "Work"))

# Test for the differences in the mean travelling TIME.MIN. for PURPOSE (University and Work)
t.test(Y1,Y2)

####### 6. #######
# Test for the difference in the mean of multiple independent groups using ANOVA techniques 

# Boxplot TIME.MIN and TRANSPORT_TYPE
boxplot(TIME.MIN.~TRANSPORT_TYPE, col=c("light blue","orange","blue"), xlab="Transport type", ylab="Time (min)")
legend("topright", inset=0.03, c("Private transport","Public transport", "Walking"), fill=c("light blue","orange","blue"), cex=0.8, text.font = 3)

# Test for differences in the mean travelling TIME.MIN. for different TRANSPORT_TYPE (Private transport, Public transport and Walking)
summary(aov(TIME.MIN.~TRANSPORT_TYPE))

####### 7. #######
# Test for the difference in the mean of two paired samples

# Test for the difference in the mean of TIME.MIN. and DISTANCE.KM.
t.test(TIME.MIN.,DISTANCE.KM., paired=T)

####### 8. #######
# Test for the linear dependence in between two paired.

# Linear dependence test between TIME.MIN. and DISTANCE.KM.
cor.test(TIME.MIN.,DISTANCE.KM.)
lm(TIME.MIN.~DISTANCE.KM.)
lm(log(TIME.MIN.)~log(DISTANCE.KM.))

plot(log(TIME.MIN.)~log(DISTANCE.KM.))
abline(lm(log(TIME.MIN.)~log(DISTANCE.KM.)))