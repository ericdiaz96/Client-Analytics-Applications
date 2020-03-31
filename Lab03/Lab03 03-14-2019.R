# Lab 3
# from "Data Mining INFS348-SPRING-2019" 
#######################################################################
## Step 1A: Download the file "credit.csv" from Sakai and save them in a 
## folder LAB04. I will refer your location as yourdirectory 
## A brief note about the data - it is related to lending/credit and 
## defaults on the loan committed by customers.  As a bank, we need to 
## find out a way to identify these bad loans before they happen and 
## improve lending practice. 
## Step 1B: Open the file in Excel and examine all the variables.  
## Our target variable is default and other variables are predictor of
## default. 
########################################################################

## Step 2: Exploring and preparing the data
## As we have done in previous class set the working directory to the folder of downloaded file

setwd("folder-location")

## Now lets read the in a variable in R.  The variable will be a dataframe. 
credit <- read.csv("credit.csv")
## Lets examine the structure of data frame and find out type of variables, example values etc. 
str(credit)
## See how many bad loans we have in the dataset.
## We will create a 1 way contingency table to tabulate total of bad vs good loans. 
# look at the class variable
table(credit$default)
## As I explained in the class, for predictive modelling, we need two pieces of data. 
## a) training dataset so that our algorithm could learn rules of the game
## b) testing dataset to see how good our algorithm is at predicting bad loans. 
## since data from the data warehouse or other sources may be sorted in a logical way (bad loans first or high amount last etc.)
## we need to get a randomize our dataset and then cut training and test dataset. 
# create a random sample for training and test data
# use set.seed as we did in clustering so that we could repeat our script without getting random set again and again. 
## I set it to 123 but you can set it to anything you want. 
set.seed(123)
## now lets cut a random sample of 900 values out of 1000 values 
train_sample <- sample(1000, 900)
## look at the structure of train_sample variable.  You will see 900 random numbers between 1 to 1000
str(train_sample)
## Now lets use these 900 numbers to select rows in our credit dataframe.  this way we get random rows from
## our credit dataframe. In plain english, this says, give me random rows as in train_sample and return all columns - remember nothing after comma.
## This will be our training dataset.  
credit_train <- credit[train_sample, ]
## minus sign ahead of train_sample reverse the meaning.  Now it says give me all rows that are not in train_sample.  This will be our testing dataset
credit_test  <- credit[-train_sample, ]
## I am done with creating training and testing datasets but do they have same proportion of bad and good loans?  That is important because in the 
## worst example, if my training dataset has no bad loans, it will be never learn what leads to bad loan. 
# Following command checks the proportion of class variable in training and test dataset.  Just table gives you exact counts of rows with good and bad. 
## In order to get proportions, we use function prop.table (prop stands for proportion) on top of table function. 
prop.table(table(credit_train$default))

## it seems that proportions are almost same as entire dataset (70:30).  So lets start training our model. 
## Step 3: Training a model on the data ----
## First install the package called C50
install.packages("party")
## Call the library of C50 and build the simplest decision tree.
library("party")

## function C5.0 calls decision tree algorithm.  First argument is the dataframe with predictors variables and second argument is the target. 
## again credit_train[-17] means exclude 17th column which is default column.  We do this because default column is not predictor but target. 
credit_model <- C5.0(credit_train[-17], credit_train$default)

# display simple facts about the tree.  Just type credit_model to see details of the credit_model DS object. 
credit_model
## similarly, see the summary of the model we have created by using summary function. 
# display detailed information about the tree
summary(credit_model)
## Read the rules for spliting followed by yes and no followed by proportions/counts of how many rows were classified correctly vs incorrectly. 
## Step 4: Evaluating model performance
## so far, we have trained our model but we need to see how well it does on the testing dataset which it has not see so far. 
## for this we use predict function of C50 package which takes two arguments. First is the model that we created out of training dataset and 
##second, the test data frame.  This leads to creation of a factor vector of predictions on test data
credit_pred <- predict(credit_model, credit_test)
## In order for us to say we are doing a decent job of finding out bad or good loans, we need to compare this factor vector with original default values
## crosstable function in gmodels package is an easy way to do that so lets install the package.  
install.packages("gmodels")
# cross tabulation of predicted versus actual classes and hence load the library. 
library(gmodels)
## corsstable function takes default from the credit_test dataframe and compares it with credit_pred.  We have turned of chi-square statistics,
## row and column proportion statistics off to keep picture clearer. dnn gives the names to dimensions. 
CrossTable(credit_test$default, credit_pred,
           prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,
           dnn = c('actual default', 'predicted default'))

## Step 5: Improving model performance
## Okay so now how can I improve my model?  Boosting is one thing we talked in the class so lets give it a try. 
## Boosting is same as ordinary simple decision tree but needs an argument about how many trees we need to grow. 
## I choose 10.  Usually there is not benefit of going beyond 10 but you can try and experiment. 
## Boosting the accuracy of decision trees - trials means how many trees I grow. 
# boosted decision tree with 10 trials
credit_boost10 <- C5.0(credit_train[-17], credit_train$default,
                       trials = 10)
## Look a the model and also summarize the model to see details. 					   
credit_boost10  
## there is not much information there but tree sizes and iterations but you will find tons of information in summmary. 
## concentrate on bottom of the summary where it shows the confusion matrix and variable importance in decending order. 
summary(credit_boost10)
## Okay, we are done with training so lets do prediction on our test dataset and see how good our model is. 
## syntax is exactly same as simpler tree. 
credit_boost_pred10 <- predict(credit_boost10, credit_test)
## similar to previous steps, we do cross table to see predicted vs actual. 
CrossTable(credit_test$default, credit_boost_pred10,
           prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,
           dnn = c('actual default', 'predicted default'))




