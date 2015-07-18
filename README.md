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
  1. getMeanStdFeatures grep the index of feature name with get "Mean" and "Std"
1. getSubjectData extract subject_train.txt, subject_test.txt to get the subject who performed the activity
1. getTriaxialDataMeanSd to extract data files under directory of "Inertial Signals", calcuate the mean and standard deviation of each 128 reading data for each triaxialName 
  1. "body_acc_x", "body_acc_y","body_acc_z"
  1. "body_gyro_x", "body_gyro_y", "body_gyro_z"
  1. "total_acc_x", "total_acc_y", "total_acc_z"
1. mergetData to create one data table with Activity, Subject, Features, TriaxialDataMeanSd, detail columns see cookbook
1. getTidyData convert the data to another tidy data set with the average of each variable for each activity and each subject
  1. codebook for merge data
  1. codebook for tidy data

### Install libraries before running run_analysis.R
using 3 packages 
1. dplyr select column
1. data.table(1.9.5) required OS support sed to convert 
1. convert merge data to tidy 
```
* require dplyr
install.packages("dplyr") 
library(dplyr) 
* require data.table develop version 1.9.5 , remove mark if you want to install develop version of data.table
#remove.packages("data.table")         
#library(devtools)    
#install_github("Rdatatable/data.table", build_vignettes = FALSE) 
#library(data.table) 
```

### How to Create  
```
setwd("/Users/powertsai/Dropbox/R/CleaningData") #work directory with "UCI HAR Dataset" and run_analysis.R
source("run_analysis.R")
trainData <- mergetData()
tidyData <- getTidyData(trainData)
```

### Time elapsed
method |  user  | system | elapsed  
------ | ------ | ------ | -------
   1   | 26.778 |  1.120 | 28.847 
   2   | 45.769 |  0.537 | 46.517 
* mthoed 1: use sed to convert tab file to csv then using fread to read data file
* method 2: use read.table to read data file


### Reference
1.[Use sed and fread ](http://stackoverflow.com/questions/22229109/r-data-table-fread-command-how-to-read-large-files-with-irregular-separators) I found this post that helps me to use fread to read data file

2.[Citation Request](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. A Public Domain Dataset for Human Activity Recognition Using Smartphones. 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, ESANN 2013. Bruges, Belgium 24-26 April 2013.

3.[Github Markdown]How to use Markdown at Github (https://guides.github.com/features/mastering-markdown/)
 

