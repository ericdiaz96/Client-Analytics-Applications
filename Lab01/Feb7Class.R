#Lab 1, First set your working directory to the appropriate path.
setwd("~/Desktop/Lab01")
getwd()

#How to read the table
lab1 <-read.table("lab1_01.txt", sep="|", header = TRUE)

lab2 <-read.table("lab1_02.txt", sep="|", header= TRUE)

#Now we will be looking at Data Values
head(lab1, n=10) #Created a variable head called LAB1 with Top 10 variables
tail(lab2, n=10) #Last 10 variables

#taking a look at a list of objectives that is in my WORKSPACE ------>
ls()

#Summary of the variables
summary(lab1)

#Read the data type by using Class(VARIABLE NAME)
class(lab1)

# and remove some extraneous variables (columns). "Serial No" #does not serve has any good

nlab1 <- lab1[,2:3]
nlab12 <- lab1[2:3]
summary(nlab12)


# what did we get? 
#How do we get the 5th row, column 3?
lab1[5,3]
#What about the entire 5th row
lab1[5,1]
#Rows 1-5 and column 5?
lab1[1:5,5]
## show me how may rows and columns - DIM is 
dim(nlab1)
## What is the type of the element in this variable. 
typeof(nlab1)
## Why list? Lets see the type of variable itself
class(nlab1)

#Are there correlations between any values? - Meaning is one thing affected by another? And if so how strong is it?
cor(nlab1)


# clean up and save

rm(lab1) #removes the file from the directory
lab1 <- nlab1
save(lab1, lab2, file="Labs.Rdata")
rm(lab1, lab2)
ls()      # make sure they?re not in the workspace
## What if you have 100 objects in workspace, how would you
## delete all the objects? 
rm(list=ls())


###################################################
## Step 1: scalars and strings
###################################################

n <- 1  # scalar
s <- "Loyola University Chicago FALL 2015"   # string 

###################################################
## Step 2: vectors of strings and numbers
################################################### 

levels <- c("Worst", "Bad", "Mediocre", "Good", "Awesome")
ratings <- c("Worst", "Worst", "Bad", "Bad", "Good", "Bad", "Bad") 
critics <- c("Siskel", "Ebert", "Rowen", "Martin")
movies <- c("The Undefeated", "Snakes on a Plane", "Encino Man", "Casablanca")
attendance <- c(15, 350,175, 400)
reviewers <- c("Siskel", "Siskel", "Ebert", "Ebert", "Rowan", "Martin", "Rowan")

###################################################

###################################################
## Step 3: factors and lists
###################################################
f <- factor(ratings, levels)  

fl <- list(ratings=ratings, critics=critics, 
           movies=movies, attendance=attendance)

###################################################
## Step 4: Matrices, Tables, and Data Frames
###################################################

mdat <- matrix(c(1,2,3, 11,12,13), nrow = 2, ncol=3, byrow=TRUE,
               dimnames = list(c("row1", "row2"),
                               c("C1", "C2", "C3")))

t <- table(ratings, reviewers)  

## do the same thing with another route
## cbind combines two vectors by column. Wonder what rbind does? 
## does it bind by rows? 
ti <-cbind(ratings, reviewers) #Rating becomes one column and reviewers become the second bind
print(ti)
class(ti)

tr <-rbind(ratings, reviewers)
print(tr)
class(tr)

## as.data.frame converts ti to a dataframe AS allows two matrices to create a dfm
td <-as.data.frame(ti)
class(td)

t<-table(td)
print(t)
###################################################
## Step 5: Defining a Function
###################################################

standev <- function(x) sd(x)   # defining a function 
v <- c(1:100)              # create a test vector
standev(v)

## How to install packages
install.packages("rattle")
## Choose USA CA2 or any USA repo
## Call library to install the function
library(rattle)
## call the function
rattle()
## See if the window opens.
## How to connect to PostgreSQL database. Install package first. 
install.packages("RPostgreSQL")
install.packages("RPostgreSQL", dep=TRUE) #It will install all of the packages that are needed to run everything
## Call the library
library(RPostgreSQL)
## establish the connection
conn<-dbConnect("PostgreSQL",dbname="infs494",host="147.126.64.66", port=8432, user="dataminer8", password="spring2019")
## query the data and put it in a variable. 
mytable=dbGetQuery(conn, "select * from student")
## See the type of variable 
class(mytable)
str(mytable) #STR = Structure

summary(mytable$gradyear)
## Could you select the second entry of the column fname
mytable$fname[2]
###################################################
## End 
###################################################
