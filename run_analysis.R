setwd("/Users/powertsai/Dropbox/R/CleaningData")
# set the UCI HAR data set directory 
dir = "UCI HAR Dataset"
# set the features file names
featureFile = paste(dir, "features.txt", sep="/") 
# set the activity labels file names
activityLabelFile = paste(dir, "activity_labels.txt", sep="/")
# set the train directory 
traindir = paste(dir, "train", sep="/") 
# set the test directory
testdir =  paste(dir, "test", sep="/") 
# set the Train Inertial Signals
trainTriaxialDir = paste(traindir, "Inertial Signals", sep="/") 

# set the Train Inertial Signals
testTriaxialDir = paste(testdir, "Inertial Signals", sep="/") 

# set tidy data set full file path
tidyfilepath = "tidyData.txt"

# pattern to find the features of mean and standard deviation
# I use "mean()| std()" to find the features for this case
grepMeanStd = "mean\\(\\)|std\\(\\)"

#need sed and data.table 1.9.5 to use fread, check user system requirement
useFread = grep("x86_64-apple", R.Version()$platform) > 0 && packageVersion("data.table") == "1.9.5" 
print(paste("useFread", useFread, sep="= "))

#get activity label from "activity_labels.txt" 
getActivityLabels <- function(chkRows = 6) {
        activitylabels <-  read.table(activityLabelFile, header=FALSE)
        order(activitylabels[,1])
        if(dim(activitylabels)[1] != chkRows) {
                stop("invalid activity_labels") 
        }
        return (activitylabels[,2])
}

#variable to keep activity labels
labels = getActivityLabels()
#convert activities variable to descriptive activity label name
getLabelName <- function(x) {
        labels[as.numeric(x)]
}

#get 561 Features name "features.txt"
getFeatures <- function(chkRows = 561) {
        features <-  read.table(featureFile, header=FALSE)
        order(features[,1])
        if(dim(features)[1] != chkRows) {
                stop("invalid features") 
        }
        return (as.vector(features[,2]))
}

#getDataTable function used to read data file to data.table
#read first 5 rows to get column classes first
#If useFread = TRUE, sed to convert tab to csv format and then using fread to read data
#If useFread = FALSE, call data.table to read data
getDataTable <- function(origfile) {
        x <- read.table(origfile,  nrows=5, header=FALSE)
        col.classes <- sapply(x, class)
        
        #embrace filename with ''
        if(useFread) {
                fileName = paste("'", origfile, "'", sep='')
                fread(paste("sed 's/^[[:blank:]]*//;s/[[:blank:]]\\{1,\\}/,/g'", fileName), colClasses = col.classes , header = FALSE)
        } else {
                data <- read.table(origfile, colClasses = col.classes , header = FALSE)
                data.table(data)
        }
}

# getData function combines the train/test one data.table
# it also checks the column size for each data set
# this function is use to read data mention belowed
# 1.get A 561-feature vector with time and frequency domain variables
#   e.g. train/X_train.txt, test/X_test.txt
# 2.get subject who performed the activity 
#   e.g. train/y_train.txt, test/y_test.txt
# 3.get activity labels from train/test set
#   e.g. train/subject_train.txt, test/subject_test.txt
getData <- function(trainfile , testfile, chkColumns){
        # call getDataTable read train file to data table
        xtrainDT <-  getDataTable(paste(traindir, trainfile, sep="/"))
        # read test file to data frame 
        xtestDT <- getDataTable(paste(testdir, testfile, sep="/"))
        # combine train set to one data frame
        lTrain = list(xtrainDT,xtestDT)
        xTrainingSet <-rbindlist(lTrain, use.names=FALSE, fill=FALSE)
        # check columns size 
        if(dim(xTrainingSet)[2] != chkColumns) {
                stop("invalid Train/Test Set") 
        }
        return (xTrainingSet)
}


#get Mean and Std Features column Index
getMeanStdFeatures <- function(features = getFeatures()) {
        # Find the Features with "mean", case insensitive
        meanstdfeatures <- grep(grepMeanStd, features, ignore.case = TRUE)
        return (meanstdfeatures)
}


#getTriaxialDataMeanSd function extract data files under directory of "Inertial Signals"
# calcuate the mean and standard deviation for each 128 reading data and return data.table
# parameter 1: triaxialName is 
#   "body_acc_x", "body_acc_y","body_acc_z", 
#   "body_gyro_x", "body_gyro_y", "body_gyro_z",
#   "total_acc_x", "total_acc_y", "total_acc_z"
# parameter 2: trainfile name is ${triaxialName}_train.txt
# parameter 3: testfile name is ${triaxialName}_test.txt
# Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
# Triaxial Angular velocity from the gyroscope. 
getTriaxialDataMeanSd <- function(
                    triaxialName,
                    trainfile = paste(triaxialName,"train.txt", sep="_"),
                    testfile = paste(triaxialName,"test.txt", sep="_") ){
        # read Triaxial train file to data frame and convert to data.table
        xtrain <- getDataTable(paste(trainTriaxialDir, trainfile, sep="/"))

         # read Triaxial test file to data frame and convert to data.table
        xtest  <- getDataTable(paste(testTriaxialDir, testfile, sep="/"))
        
        # combine train set to one data table
        xTriaxialSet <-rbind.data.frame(xtrain, xtest)

        # check columns size 
        chkColumns = 128
        if(dim(xTriaxialSet)[2] != chkColumns) {
                stop("invalid Triaxial Train/Test Set") 
        }

        # create row mean for each train/test set 
        triaialMean <-  rowSums(xTriaxialSet) 
        
        # create row standard deviation for each train/test set
        triaialSd <- apply(xTriaxialSet, 1, sd)
        # combine mean and sd to one data frame
        triaialMeanStd <- cbind.data.frame(triaialMean, triaialSd)
        # set column names
        names(triaialMeanStd) <- c(paste(triaxialName, "mean", sep="_"), 
                                   paste(triaxialName, "std", sep="_"))

        data.table(triaialMeanStd)
}

#get Subject Data from "subject_train.txt" and  "subject_test.txt"
#set Column Name to Subject
getSubjectData <- function() {
        trainData <-  getData( trainfile = "subject_train.txt", testfile = "subject_test.txt", chkColumns = 1)
        setNames(trainData , "Subject") 
}

#get Activity Data from "y_train.txt" and  "y_test.txt"
#set Column Name to Activity
getActivityData <- function() {
        ytrain <-  getData( trainfile = "y_train.txt", testfile = "y_test.txt", chkColumns = 1 )
        #change activity to descriptive activity label name
        actLabelNames <- apply(ytrain, 1, getLabelName)
        
        setNames(data.table(actLabelNames), "Activity")
}


#get Features Data from "X_train.txt" and  "X_test.txt"
#set Column Name by festure.txt
getFeaturesData <- function() {
        #get Features Data by  "X_train.txt" and "X_test.txt", check Column size = 561
        xtrain <- getData(trainfile =  "X_train.txt",  testfile = "X_test.txt", chkColumns = 561)
        #get Features Names by "features.txt"
        features <- getFeatures()
        
        desFeatures <- sapply(features, changeDescriptiveName)
        
        xtrain <- setNames(xtrain , desFeatures) 
        
        names(xtrain)
        #select column names with mean and std
        return (select(xtrain, getMeanStdFeatures(features)))
}


changeDescriptiveName <- function(featureName) {
        descName <- gsub("[_\\(\\)-]","", featureName)
        descName <- tolower(descName)
}

mergetData <- function() {
        #get train/test set's subject: who performed the activity for each window sample from train/test set. 
        #Its range is from 1 to 30. 
        trainData <- getSubjectData()
        #get train/test set's activity label
        actLabelNames <- getActivityData()
        #2.Activity Label Name
        trainData <- cbind(trainData, actLabelNames)

        #get A 561-feature vector with time and frequency domain variables
        #column name with mean / std
        xtrain <- getFeaturesData()
        trainData <- cbind(trainData, xtrain)

        #Read Inertial Signals data for each sensor
        triaxialNames <- c("body_acc_x","body_acc_y","body_acc_z", 
                           "body_gyro_x", "body_gyro_y", "body_gyro_z",
                           "total_acc_x", "total_acc_y", "total_acc_z"
                           )
        
        #for each sensor get the the Mean and Standard Deviation from 128 reading data 
        #cbind the data to trainData
        for(triaxialName in triaxialNames) {
                triaxialMeanStd <-  getTriaxialDataMeanSd(triaxialName=triaxialName)
                trainData <- cbind(trainData, triaxialMeanStd)        
        }
        return (trainData)

}

#use shape2 library to melt merge data 
#group by Subject , Activity, Measurement
#Summaryize value with Mean(value)
#write tidydata to file at defined tidyfilepath
getTidyData <- function(mergeData) {
        #melt data.table to subject, activity, measurement, value
        meltData <- melt(mergeData, id=c("Subject","Activity"),
             measure.vars=names(trainData)[3:length(names(trainData))]) 
        #set descriptive column names 
        meltData <- setNames(tidyData, c("subject","activity","measurement", "value"))
        print(paste("dim(TidyData)",dim(tidyData)))
        tidyData <- meltData %>%  
        #group by subject,activity, measurement
        group_by(subject,activity, measurement)  %>%
        #summarise by mean for each value
        summarise(mean = mean(value)) 
        print(paste("dim(TidyData)",dim(tidyData)))
        #write tidy data to define filepathy
        write.table(tidyData, tidyfilepath, quote = FALSE, col.names = TRUE, row.names = FALSE)
        return (tidyData)
}