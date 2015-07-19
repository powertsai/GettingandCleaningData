### Courese project objectives:
1. You should create one R script called run_analysis.R that does the following. 
1. Merges the training and the test sets to create one data set.
1. Extracts only the measurements on the mean and standard deviation for each measurement. 
1. Uses descriptive activity names to name the activities in the data set
1. Appropriately labels the data set with descriptive variable names. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### function defined in run_analysis.R to created the merge data and tidy data 
1. getData combine the train/test data into one data.table
  1. getDataTable read data file to data.table
1. getActivityData extract y_train.txt, y_test.txt convert to descriptive activity label name
  1. getActivityLabels get activity label from "activity_labels.txt" 
  1. getLabelName convert activities value to its label name
1. getFeaturesData extract X_train.txt, x_test.test to get 561-feature variables, and select feature name with (mean|std) 
  1. getFeatures read 561 features names from "features.txt"
  1. getMeanStdFeatures grep the index of feature name with get "mean" and "std" (ignore case)
  1. changeDescriptiveName to change feature to be more descriptive (lowercase, remove(), substitute non(a-zA-Z0-9) to .
1. getSubjectData extract subject_train.txt, subject_test.txt to get the subject who performed the activity
1. data files under directory of "Inertial Signals" have no column names definition, can't find the data related to mean/standard deviation, didn't implemnt funtion to deal with
1. mergetData to create one data table with Activity, Subject, Features, TriaxialDataMeanSd
  1. [codebook](mergedDataCodeBook.md) for merge data
1. getTidyData convert the data to another tidy data set with the average of each variable for each activity and each subject
  1. [codebook](tidyDataCodeBook.md) for tidy data

### function defined in loadLibrary.R 
1. loadLibrary: check if library installed then load the required library
1. loadDevDataTable: install the data.table version 1.9.5 for using fread to read large data file

### Install libraries before running run_analysis.R
```
#YourWorkDirectory is the work directory with loadLibrary.R download from Github
setwd("/Users/YourWorkDirectory")  
source("loadLibrary.R")
#require dplyr to select column, group_by, summarise
loadLibrary("dplyr")
#require reshape2 to melt merge data into narrow tidy data set 
loadLibrary("reshape2")
#require data.table(1.9.5) to fread large data file 
loadDevDataTable("data.table")

#remove mark #, and switch data.table back to CRAN version
#remove.packages("data.table")         # First remove the current version
#install.packages("data.table")        # Then install the CRAN version
```

### How to call run_analysis.R to create tidy data to review  
```
#YourWorkDirectory is the work directory with UCI HAR Dataset and run_analysis.R download from Github
setwd("/Users/YourWorkDirectory") 
source("run_analysis.R")
#merge data files in one data set
system.time(mergeData <- mergetData())
#get independent tidy data set with the average of each variable for each activity and each subject.
system.time(tidyData <- getTidyData(mergeData))
# Write tidy data to tidyfilepath
tidyfilepath = "tidyData.txt"
write.table(tidyData, tidyfilepath, quote = FALSE, col.names = TRUE, row.names = FALSE)
data <- read.table(tidyfilepath, header = TRUE)
#View tidy data created 
View(data))
#delete the tidy data file
file.remove(tidyfilepath)
```

### Time elapsed
method |  user  | system | elapsed  
------ | ------ | ------ | -------
   1   | 26.778 |  1.120 | 28.847 
   2   | 45.769 |  0.537 | 46.517 
* mthoed 1: use sed to convert tab file to csv then using fread to read data file
* method 2: use read.table to read data file


### Reference
1. [David's personal course project FAQ](https://class.coursera.org/getdata-030/forum/thread?thread_id=37)
2. [Citation Request](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. A Public Domain Dataset for Human Activity Recognition Using Smartphones. 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, ESANN 2013. Bruges, Belgium 24-26 April 2013.
3. [Github Markdown](https://guides.github.com/features/mastering-markdown/)

 

