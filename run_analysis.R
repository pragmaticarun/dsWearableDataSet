#Author: Arunkumar M R
#depends on 
#  read.table
#  package2
#Created Date
#  24-apr-2016

#This R program performs the following

#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard 
#   deviation for each measurement.
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names.
#5. From the data set in step 4, creates a second, independent 
#   tidy data set with the average of each variable for each 
#   activity and each subject.

# Download the zip file containing data

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "./acc.zip")

#Unzip and change the current directory to unzipped directory

unzip("./acc.zip")
setwd("UCI HAR Dataset/")

# Load test and Training data
X_test <-  read.table(file="./test/X_test.txt",header=FALSE)
Y_test <-  read.table(file="./test/y_test.txt",header=FALSE)
Y_train <-  read.table(file="./train/y_train.txt",header=FALSE)
X_train <-  read.table(file="./train/X_train.txt",header=FALSE)

#Merge Training and test set
X <- rbind(X_train,X_test)
Y <- rbind(Y_train,Y_test)

#Set activity labels instead of numbers
Y$V1 <- factor(Y$V1,labels=c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING"))

#Set feature names descriptive- Use data from features.txt

featurenames <- read.table("features.txt",as.is=TRUE)
names(X) <- featurenames$V2

#Extract mean and std cols in features
meanCols <- grep("mean\\(",names(X))
stdCols <- grep("std\\(",names(X))
exCols <-  sort(c(meanCols,stdCols))
newX <- X[,exCols]

#Add Activity Column
names(Y) <- "Activity"
newTab <- cbind(newX,Y)

#Add Subjects column
ste <- read.table("test/subject_test.txt",header=FALSE)
sT <- read.table("train/subject_train.txt",header=FALSE)
subject <- rbind(sT,ste)
names(subject) <- "Subjects"
newTab <- cbind(subject,newTab)

#Construct new dataset with mean for each subject and activity
#install.packages("reshape2")
library(reshape2)
a <- melt(newTab,id=c("Subjects","Activity"))
final <- dcast(a,Subjects + Activity ~ variable,mean)

#Write the new dataset to the file
write.table(x=final,file="./tidy_dataset.txt",row.names=FALSE)

