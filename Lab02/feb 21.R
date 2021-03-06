# Lab 2
# from "Data Mining INFS348- SPRING-2016" 
#
#############################################################
## Step 0: Getting started with R
## Download the file "groceries.csv" from Sakai and save them in a 
## folder LAB02. I will refer your location as yourdirectory 
#############################################################
##Inspect the file in Notepad look at the structure
##load the file in database.  I have already put the file on server. The
##command to put the file in a table is as follows:
##create the empty staging table first
create table grocery(line text);
## Copy the data in this table. 
copy grocery from 'D:\data\LAB02\groceries.csv'
## In this format file is not very useful. So lets tranform it into vertical format
## where one row correspond to one item in a given transaction. Lets put this into a view
## put your accountname after vertical in the view name eg. grocery_vertical_dataminer1. 
## We need a transaction identifier that is what row_number()... is doing.
CREATE VIEW grocery_vertical
AS
SELECT tid,
regexp_split_to_table(line, ',')
FROM (SELECT row_number() over () AS tid,line FROM grocery) as foo;

## set your working directory. 

setwd("yourdirectory/LAB02")
## load library for PostgreSQL
library(RPostgreSQL)
conn<-dbConnect("PostgreSQL",dbname="infs494",host="147.126.64.66", port=8432, user="dataminer8", password="spring2019")
gr=dbGetQuery(conn,"select * from grocery_vertical")
# load the association library
# change the names of columns
colnames(gr)=c("tid","items")
install.packages("arules")
library(arules)
## for each TID split the dataset and then convert it into class "transactions"
groceries=as(split(gr$items,gr$tid),"transactions")
summary(groceries)

# look at the first five transactions
inspect(groceries[1:5])

# examine the frequency of items
itemFrequency(groceries[, 1:3])

# plot the frequency of items

itemFrequencyPlot(groceries, support = 0.1)
itemFrequencyPlot(groceries, topN = 20)
itemFrequencyPlot(groceries, support = 0.1,topN=20)

# a visualization of the sparse matrix for the first five transactions
image(groceries[1:5])

# visualization of a random sample of 100 transactions
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

# finding subsets of rules containing any berry items
berryrules <- subset(groceryrules, items %in% "berries")
inspect(berryrules)

# writing the rules to a CSV file
write(groceryrules, file = "groceryrules.csv",
      sep = ",", quote = TRUE, row.names = FALSE)

# converting the rule set to a data frame
groceryrules_df <- as(groceryrules, "data.frame")
str(groceryrules_df)
## write the rules to a file for further digging.  row.names are set to false so that we do not get first columns. 
## quotes are set to false so that files come out neat. sep is set to be pipe. file location is d:/grule.txt
write.table(groceryrules_df,file ="d:/grule.txt",sep="|",quote = FALSE,row.names=FALSE)

install.packages("RPostgreSQL")

conn<-dbConnect("PostgreSQL",dbname="infs494",host="147.126.64.66", port=8432, user="dataminer8", password="spring2019")
gr=dbGetQuery(conn,"select * from grocery_vertical")

colnames(gr)=C("tid", "items")
