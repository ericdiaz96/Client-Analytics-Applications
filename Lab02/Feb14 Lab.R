setwd("~/Desktop/Lab02")

##Install the Package
install.packages("arules")

##View the library
library("arules")

#list Files
list.files()

#read the transaction
groceries <- read.transactions("groceries.csv", sep = ",")

#Summary of the groceries
summary(groceries)

#Inspect the top five transactions
inspect(groceries[1:5])

#frequency of each item
itemFrequency(groceries[,1:3])

# a visualization of the sparse matrix for the first five transactions
image(groceries[1:5])

# visualization of a random sample of 100 transactions
#Represent the transaction number, if there are some not in that line get rid of that product
image(sample(groceries, 100))

#apriori algorith
apriori(groceries)

# set better support and confidence levels to learn more rules
groceryrules <- apriori(groceries, parameter = list(support =
                                                      0.006, confidence = 0.25, minlen = 2))
groceryrules

## Step 4: Evaluating model performance ----
summary of grocery association rules
summary(groceryrules)

# look at the first three rules
inspect(groceryrules[1:3]) #Groceries 1,2,3 - inspect and look at the transactions

#use sample to take a random sample of 100 rows
# visualization of a random sample of 100 transactions - Two dots that are always together, we can do a plot with them together
image(sample(groceries, 100))


# default settings result in zero rules learned
apriori(groceries)

# set better support and confidence levels to learn more rules
groceryrules <- apriori(groceries, parameter = list(support =
                                                      0.006, confidence = 0.25, minlen = 2))
groceryrules

## Step 4: Evaluating model performance ----
# summary of grocery association rules
summary(groceryrules)

# look at the first three rules
inspect(groceryrules[1:3])

## Step 5: Improving model performance ----

# sorting grocery rules by lift
inspect(sort(groceryrules, by = "lift")[1:5])

#What is the lift formula?
# Supp(x->y)/ Conf(y)

# finding subsets of rules containing any berry items
berryrules <- subset(groceryrules, items %in% "berries")
inspect(berryrules)
#think about confidence - flip it around (0.27 -con, 73% there is NOT sour creme)
#to have tofu, berries and berries USE %pin% - partial IN
#to have %ain% c(berries, tofu)

#How do we know that are rules are useful?
# writing the rules to a CSV file
write(groceryrules, file = "groceryrules.csv",
      sep = ",", quote = TRUE, row.names = FALSE) #True or False in are should be in CAPS

# converting the rule set to a data frame
groceryrules_df <- as(groceryrules, "data.frame")
str(groceryrules_df)
## write the rules to a file for further digging.  row.names are set to false so that we do not get first columns. 
## quotes are set to false so that files come out neat. sep is set to be pipe. file location is d:/grule.txt
write.table(groceryrules_df,file ="d:/grule.txt",sep="|",quote = FALSE,row.names=FALSE)
