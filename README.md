This README explains the run_analysis.R script which cleans up the wearable data.

# 1. Download the zip file containing data

The first step is to download the zip file containing the data
```R
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              destfile = "./acc.zip")
```

#2. Unzip and change the current directory to unzipped directory

Next step is to unzip the downloaded file and set the current directory to the new directory.
This is to enable the ease of using the data files inside.

```R
unzip("./acc.zip")
setwd("UCI HAR Dataset/")
```

#3. Load test and Training data

Load the test and training data for features and activities. This script uses
read.table for loading the data value. specify header=FALSE as there is no header in the 
data files

```R
X_test <-  read.table(file="./test/X_test.txt",header=FALSE)
Y_test <-  read.table(file="./test/y_test.txt",header=FALSE)
Y_train <-  read.table(file="./train/y_train.txt",header=FALSE)
X_train <-  read.table(file="./train/X_train.txt",header=FALSE)
```

#4. Merge Training and test set

Use R bind the merge training and test data. Care should be taken as to training or test data comes
first. The same order should be followed when combining training and test data for 
Activity and subject data

```R
X <- rbind(X_train,X_test)
Y <- rbind(Y_train,Y_test)
```

#5. Set activity labels instead of numbers

Set the number in the activity with the meaningful activity labels and convert into factors. The reason is that in the end
it will be useful to group based on activity.

```R
Y$V1 <- factor(Y$V1,labels=c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING"))
```

#6. Set feature names descriptive- Use data from features.txt

To have meaningful feature names extract the feature names from features.txt in the root of the extracted folder.
It is painful to name it manually.

```R
featurenames <- read.table("features.txt",as.is=TRUE)
names(X) <- featurenames$V2
```

#7. Extract mean and std cols in features

Use regex to extract only the mean and std deviation of measurements.

```R
meanCols <- grep("mean\\(",names(X))
stdCols <- grep("std\\(",names(X))
exCols <-  sort(c(meanCols,stdCols))
newX <- X[,exCols]
```

#8. Add Activity Column

Assign a appropriate label for the Activity data and add it to the  feature data set. This needs
to be done because it will be easy to summarize based on activity and subject.

```R
names(Y) <- "Activity"
newTab <- cbind(newX,Y)
```

#9. Add Subjects column

Extract subject from the subject_test.txt and subject_train.txt and merge them using rbind.
Add it to the dataset contructed so far. Apply a meaningful label to the column.

```R
ste <- read.table("test/subject_test.txt",header=FALSE)
sT <- read.table("train/subject_train.txt",header=FALSE)
subject <- rbind(sT,ste)
names(subject) <- "Subjects"
newTab <- cbind(subject,newTab)
```

#10. Construct new dataset with mean for each subject and activity
#install.packages("reshape2")
Use the reshape to library to melt the dataset (group) based on subjects and activity while taking the mean function 
as the summarizing function.

```R
library(reshape2)
a <- melt(newTab,id=c("Subjects","Activity"))
final <- dcast(a,Subjects + Activity ~ variable,mean)
```

#11. Write the new dataset to the file

Last but not least. This was what we have been working for. Write the result to the file.

```R
write.table(x=final,file="./tidy_dataset.txt",row.names=FALSE)
```

