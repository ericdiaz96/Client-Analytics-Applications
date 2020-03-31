# Lab 4
# from "Data Mining INFS348 Spring 2019" 
# "#" sign means these lines are comments/documentation and not 
# the codes that need execution. 
#############################################################
## Step 1:
## The data related to Facebook or Twitter kind of website data related to 
## students who are teenagers.  Based on this data, we need to find out who 
## these folks are and what we can sell to them. 
##Inspect the data in the database (table is student), look at the structure, categorical/textual/numeric data.

## Step 2: 
##Exploring and preparing the data ----
## set your working directory- we have done it million times already. 
> setwd("~/Documents/Senior/Spring 2019/INFS 348/Lab04")
## Data about teens is in student table on the database. So lets log into the database and see the structure. 
library(RPostgreSQL)
conn<-dbConnect("PostgreSQL",dbname="infs494",host="147.126.64.66", port=8432, user="dataminer8", password="spring2019")
teens <-dbGetQuery(conn,"select * from student")
## What would be the class of teens variable? This is a question, consult lab01 and lab02
## Lets see the structure of the teens. How many columns and rows are there in it. 
##str command does that for us. 
str(teens)
## dbGetQuery does not convert strings to factors so lets do it explicitly by as.factor command
teens$gender=as.factor(teens$gender)
## lets summarize different features/variables of teens. 
summary(teens)
## do you spot "NA" for some variables? Which variables are those? 
## since we are using Kmeans method, missing value is an issue. 
## look at missing data for gender variable and dig deeper. 
table(teens$gender)
## but I do not see NA values in there. What is the problem? supply parameter useNA and set it to ifany or always
table(teens$gender, useNA = "ifany")
## Now I can see the NAs in the gender variable of the dataset. 
# Similarly, dig deeper in age variable.  look at missing data for age variable
summary(teens$age)
## Do you see bunch of old folks who are calling themseleves teenagers or 
##some younger children eagar to be called teens? See the min and max values of the summary. 
## Okay. So what to do for the outliers in age variable? 
## eliminate age outliers and substitute them wth NA.  We will deal with NA later in one go.
## For this, we will use ifelse function.  It means if age is greater than or equal to 13 and age is  
## age is less than 20 then value is age from the data otherwise age is NA. "&" stands for AND. 
teens$age <- ifelse(teens$age >= 13 & teens$age < 20,
                    teens$age, NA)
## now see if our function has done the magic and max and min are teen years. 					 
summary(teens$age)
## Now lets deal with NA values for both age and gender. 
## Lets work on gender first.  For categorical variables, we treat the missing values
## as a different kind of value called "unknown". in other words, we will have three genders (male, female, unknown). 

## Also, we will create two dummy variables for each distinct three value of gender.  
##unknown and female which will have values 1 (means yes) or 0 (means No)
## If both female and unknown are 0 (means NO), that implies person is male.  So there is no point in creating dummy
## variable for male. 

## In plain english, We create a variable female in dataframe teens and assign the output of ifelse function to it. 
## In ifelse function, if gender variable is equal to "F" (shown by '==') and (shown by &) and gender is not na (!is.na(teens$gender))
## then value of female dummy variable is 1 else 0.  
## = is assignment and "==" is equal condition

teens$female <- ifelse(teens$gender == "F" &
                         !is.na(teens$gender), 1, 0)
## For unknown dummmy variable, we create a variable no_gender in dataframe teens and it can have values 1 or 0.  We use ifelse function 
##to populate this variable.  In ifelse function, if gender variable is equal to "NA" (is.na(teens$gender))
## then value of no_gender dummy variable is 1 else 0. 
teens$no_gender <- ifelse(is.na(teens$gender), 1, 0)

# check our recoding work
table(teens$gender, useNA = "ifany")
table(teens$female, useNA = "ifany")
table(teens$no_gender, useNA = "ifany")
## We are done with gender variable's missing value.  Can we use the same approach for age? The answer is "NO"
## So what to do with 5K missing age values?  We will use a technique called "Imputation" which means inpute the age
## by using mathematical tricks like mean, median, mode, regression and so on. 
## So lets try finding the mean age by cohort
mean(teens$age) 
## doesn't work because age has NA and any calculation on NA produces NA.
## lets remove NA by using parameter called na.rm=TRUE 
mean(teens$age, na.rm = TRUE) 
## This works !! and average age is around 17 years. But I cannot use 17 yrs for entire data.  
##Doesn't age depends upon grad years?  So I should calculate average age by grad year and use that 
## for corresponding grad year subset of data. 
## So in plain english, this is what the next statement is doing: aggregate age by gradyear and then apply
## mean to each gradyear. Also, remove the NA (na.rm=TRUE) because otherwise mean will be null.
##Aggregate is very similar to GROUP BY
#####################APPROACH#1################################################################# 
xyz=aggregate(data = teens, age ~ gradyear, mean, na.rm = TRUE)
## Now lets see what is there in xyz
print(xyz)
## It seems that there are four rows (one for each gradyear) and respective mean age. As expected, grad year and age
## are related and hence ages are off by year based on gradyear. 
## Now lets merge this information with teens data frame.  We will match xyz with teens by gradyear. So in plain english, 
## the syntax says, merge teens and xyz by gradyear. 
## Merge is nothing but JOIN from SQL
merged_teens=merge(teens,xyz,by=c("gradyear"))
## just to check the output, see the structure of the new data frame.  You will see two ages (age.x and age.y ). Age.x is 
## the age from teens and age.y is the age from xyz. 
str(merged_teens)
## Now use new dataframe to inpute value of those ages that are missing.  In plain english, the statement as shown below says
## if age.x from merged_teens is NA then the age is age.y(age from xyz) otherwise age is age.x (the original age from teens) and 
## put this impute age in age variable of teen dataframe.  
teens$age=ifelse(is.na(merged_teens$age.x),merged_teens$age.y,merged_teens$age.x)
## check the summary to find out if things look better and age is not suffering from NAs anymore. 
summary(teens$age)
## Does this reminds you about group by, then subquery and then join in SQL? 
#####################APPROACH#2#################################################################
## Step 3: Now the data has been whipped to shape, lets do kmeans clustering: 
## Lets training a kmeans model on the data. For this, we need the K (how many clusters) and If you do str(teens) 
##you will realize that good number of our features/numeric variables are contained in columns 5 to 40.  
features <- teens[5:40]
## Remember, kmeans is very sensitive to outliers and scale.  So we need to rescale our clusters
## As a way to normalize the data, We will calculate z-score for each variable.  
## lapply function will apply scale formula (which is zscore) on each list elements. 
## Remember I have been saying for a while that data.frame is a list. So thing of our features dataframe 
## as list which looks like following: features = list(basketball=c(....), soccer=c(.....))
## lapply will normalize all values for basketball, then scoccer.....
features_norm <- as.data.frame(lapply(features, scale))
## Since kmeans clustering begins with random seed, lets set some number as seed. 
## This way, I can reproduce the same clusters again and again. Otherwise, each time I run the model, 
## it will produce a different result.  
set.seed(2345)
## Run the model/algorithm with K=5 and put the output in variables called teen_clusters
teen_clusters <- kmeans(features_norm, 5)

## Step 4: Evaluating model performance ----
# look at the size of the clusters
teen_clusters$size

# look at the cluster centers
teen_clusters$centers
## Lets write them in file and visualize in Tableau to find out who these people are. 
## Goal is to find out who can we target for marketing cosmetics, sports goods etc. 
write.csv(teen_clusters$centers,"center.txt")


## Step 5: Improving model performance ----
# apply the cluster IDs to the original data frame
teens$cluster <- teen_clusters$cluster


# look at the first five records.  Remember RC (Rows Columns), So give me 1 to 5 rows and cluster, gender, age, friends as columns 
teens[1:5, c("cluster", "gender", "age", "friends")]

# mean age by cluster - aggregate age by cluster and get the mean for each cluster.
aggregate(data = teens, age ~ cluster, mean)

# proportion of females by cluster - aggregate female column by cluster and then calculate the mean for each cluster.
aggregate(data = teens, female ~ cluster, mean)

# mean number of friends by cluster aggreate friends by cluster and calculate mean for each cluster. 
aggregate(data = teens, friends ~ cluster, mean)

