### Courese: Getting and Cleaning Data 
We are assigned to complete the course project with some objectives
1. You should create one R script called run_analysis.R that does the following. 
1. Merges the training and the test sets to create one data set.
1. Extracts only the measurements on the mean and standard deviation for each measurement. 
1. Uses descriptive activity names to name the activities in the data set
1. Appropriately labels the data set with descriptive variable names. 
From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### How to get data file 
```
setwd("/Users/powertsai/Dropbox/R/CleaningData") #work directory with "UCI HAR Dataset" and run_analysis.R
1. library(dplyr) 
1. library(data.table)
1. source("run_analysis.R")
1. trainData <- mergetData()

### Install libraries used
```
library(dplyr) 
library(data.table), if set useFread = TRUE in run_analysis.R 
#require dplyr
install.packages("dplyr")        #install the CRAN version
#require data.table 1.9.5 to use fread on Mac OS X
remove.packages("data.table")         # First remove the current version
library(devtools)    
install_github("Rdatatable/data.table", build_vignettes = FALSE)  # install 1.9.5 develop version
```

### Reference
1.[How to use fread with tab separate file](http://stackoverflow.com/questions/22229109/r-data-table-fread-command-how-to-read-large-files-with-irregular-separators)
1.[Citation Request](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. A Public Domain Dataset for Human Activity Recognition Using Smartphones. 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, ESANN 2013. Bruges, Belgium 24-26 April 2013.

Time Elapse
> useFread = TRUE    #use sed to convert tab file to csv then use fread to get data.table
> system.time(trainData <- mergetData())
   user  system elapsed 
 26.778   1.120  28.847 
> useFread = FALSE   #use read.table to get data and convet to data.table
> system.time(trainData <- mergetData())
   user  system elapsed 
 45.769   0.537  46.517 

