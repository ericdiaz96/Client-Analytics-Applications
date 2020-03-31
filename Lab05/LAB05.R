## Step 1: Exploring and preparing the data ---- 
## setwd("location of your downloaded files")
# read the credit data into the credit data frame. 
credit <- read.csv("credit.csv")
## examine the structure of the credit data.
str(credit)
## Lets look at the summmary of each variable. 
summary(credit)
## Step 2: Lets cut the data into two parts training and testing dataset. 
## Just like Lab04, we use sample command but instead of typing exact 1000 
## nrow stands for number of rows of a dataframe.  I will write nrow(credit) 
##which give me 1000 and then I take 90% of that as train_sample.
## The final result remains the same but I can use this code immaterial of the size of dataset. 
## Just to ensure I get the same result despite using random sampling, I set the set the seed to 42. 
set.seed(42)
## And now I run the sampling statement. 
train_sample=sample(nrow(credit),nrow(credit)*0.90)
## Use the random 900 number between 1 to 1000 to get random rows of credit dataframe. 
credit_train=credit[train_sample,]
## Use the remained rows for testing. - sign reverse the meaning and says that pull all those 
## that are not in train_sample into credit_test dataframe. 
credit_test=credit[-train_sample,]
## Step 3: Training a model on the data ----
##install the package for Naive Bayes Classifier. 
install.packages("e1071")
## Call the library. 
library(e1071)
## train the model. Again we use -17 to say that we do not use default to make prediction about default.  
credit_classifier <- naiveBayes(credit_train[-17], credit_train$default)
## Step 4: Evaluating model performance
credit_test_pred <- predict(credit_classifier, credit_test)
## also see what is there in credit_test_pred (all yes and nos). 
credit_test_pred
## Just like lab04, we will create the cross table to see 
## how the model is performing. Install and call library of gmodels.
install.packages("gmodels")
library(gmodels)
## Lets call function CrossTable and see the confusion matrix. 
CrossTable(credit_test_pred, credit_test$default,
           prop.chisq = FALSE, prop.t = FALSE, prop.r = FALSE,
           dnn = c('predicted', 'actual'))

## Step 5: Improving model performance
## Here we put another parameter for Laplace smoothing and put a value to 1.  
##In this case, it will not make that much of a difference but it does matter 
##a lot in sparse matrix kind of dataset(usually in text mining). 
credit_classifier2 <- naiveBayes(credit_train[-17], credit_train$default, laplace = 1)
## Lets predict our test dataset using this model. 
credit_test_pred2 <- predict(credit_classifier2, credit_test)
## Lets create a confusion matrix with CrossTable. 
CrossTable(credit_test_pred2, credit_test$default,
           prop.chisq = FALSE, prop.t = FALSE, prop.r = FALSE,
           dnn = c('predicted', 'actual'))

