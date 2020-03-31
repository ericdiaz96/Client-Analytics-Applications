##Eric Diaz
#HW1 02/25/2019

setwd("~/Documents/Senior/Spring 2019/INFS 348/HW1")
install.packages("arules")
library(arules)

## Some suggestions: clean the name of the columns in excel to make it easier to work with. 
## Do some data cleaning in excel to make life easier.  

heartdata <- read.csv("dataclean.csv", header=TRUE)
# convert the dataframe to transactions

#Remove those columns that are 100% correlated.  Hint:  Look at buff in data.
# how to do it? test1, we talked about subsetting dataframe. select only those columns that make sense. 
heartdata = heartdata[1:13] 

htrans = as(heartdata, "transactions")
 
# set better support and confidence levels to learn more rules.  If you get a lot of rules increase the support or/and confidence. 
# similarly if you get very few rules, decrease support or/confidence. 
#change the minlen to limit the number of "items". So, 2 in this case means arules with 2 items
hrules <- apriori(htrans, parameter = list(support =0.20, confidence = 0.75, minlen = 2))

#subset for  buff or healthy
hrules.sub <- subset(hrules, subset= rhs %in% "class=buff" 
                     & lift > 1.1)
#subset for sick
hrules.sub2 <-subset(hrules, subset= rhs %in% "class=sick"
                     & lift>1.1)

# subset those rules that pertain to rhs = buff or sick etc. 

hrules_df<- as(hrules, "data.frame")
hrules.sub<- as (hrules.sub, "data.frame")
hrules.sub2<- as (hrules.sub2, "data.frame")

str(hrules_df)
str(hrules.sub)
str(hrules.sub2)

# write this data frame to a text file that we will analyze usin g Tableau. 
write.table(hrules_df,file ="hrule.txt",sep="|",quote = FALSE,row.names=FALSE)
write.table(hrules.sub, file = "hruleBuff.txt", sep="|", quote = FALSE, row.names=FALSE)
write.table(hrules.sub2, file = "hruleSick.txt", sep="|", quote = FALSE, row.names=FALSE)


