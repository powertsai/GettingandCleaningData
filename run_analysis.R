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

# if version is 1.9.5 set Flag True to use fread to read data
useFread = FALSE
useFread = (packageVersion("data.table")  == "1.9.5" )

# if support sed, using it to convert data format to csv
osPlatform <- R.version$platform
supportSed = length(grep('x86_64-apple', osPlatform)) > 0

# pattern to find the features of mean and standard deviation
# I use "mean()| std()" to find the features for this case
grepMeanStd = "mean\\(\\)|std\\(\\)"


#get activity label from "activity_labels.txt" 
getActivityLabels <- function(chkRows = 6) {
        activitylabels <-  read.table(activityLabelFile, header=FALSE)
        activitylabels <- activitylabels[order(activitylabels[,1]), ]
        if(dim(activitylabels)[1] != chkRows) {
                stop("invalid activity_labels") 
        }
        return (activitylabels[,2])
}

#variable to keep activity labels
labels = getActivityLabels()
#convert activities variable to descriptive activity label name
getLabelName <- function(x) {
        paste(x,labels[as.numeric(x)],sep=".")
}

#get 561 Features name "features.txt"
getFeatures <- function(chkRows = 561) {
        features <-  read.table(featureFile, header=FALSE)
        features <- features[order(features[,1]),]
        if(dim(features)[1] != chkRows) {
                stop("invalid features") 
        }
        featureNames <- paste(features[,1], features[,2], sep=".")
        
        return (featureNames)
}

#convertToCsvFormat convert tab delimeter to common separated sheet format
convertTabToCsv <- function(data){
        csvData <-gsub("\\s+", ",", data)
        csvData <- gsub("^,","", csvData)
        return (csvData)
}

#getDataTable function used to read data file to data.table
#read first 5 rows to get column classes first
#If useFread = TRUE, sed to convert tab to csv format and then using fread to read data
#If useFread = FALSE, call data.table to read data
getDataTable <- function(origfile) {
        #get first 5 rows to get column classes
        x <- read.table(origfile,  nrows=5, header=FALSE)
        col.classes <- sapply(x, class)
        print(paste("data.table version support fread:", useFread))
        if(useFread) {
                #check if OS support sed
                print(paste("support Sed:", supportSed))
                if(supportSed) {
                        #quote file name with ''
                        fileName = paste("'", origfile, "'", sep='')
                        DT <- fread(paste("sed 's/^[[:blank:]]*//;s/[[:blank:]]\\{1,\\}/,/g'", fileName), colClasses = col.classes , header = FALSE)
                } else {
                        #Convert tab-delimited txt file into a csv file
                        tabData=fread(origfile, sep="\n", header = FALSE)
                        csvData <- sapply(tabData, convertTabToCsv)
                        tmpFile = sub("\\.txt$","_tmp\\.csv",origfile)
                        write.table(csvData, file=tmpFile, sep="", col.names =  FALSE, row.names =  FALSE, quote = FALSE);
                        
                        DT <- fread(tmpFile, colClasses = col.classes , sep=",", header = FALSE)
                        file.remove(tmpFile)
                }
        } else {
                # read table by column classes
                data <- read.table(origfile, colClasses = col.classes , header = FALSE)
                DT <- data.table(data)
        }
        return (DT)
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



#get Subject Data from "subject_train.txt" and  "subject_test.txt"
#set Column Name to Subject
getSubjectData <- function() {
        trainData <-  getData( trainfile = "subject_train.txt", testfile = "subject_test.txt", chkColumns = 1)
        setNames(trainData , "subject") 
}

#get Activity Data from "y_train.txt" and  "y_test.txt"
#set Column Name to Activity
getActivityData <- function() {
        ytrain <-  getData( trainfile = "y_train.txt", testfile = "y_test.txt", chkColumns = 1 )
        #change activity to descriptive activity label name
        actLabelNames <- apply(ytrain, 1, getLabelName)
        
        setNames(data.table(actLabelNames), "activity")
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

#make the feature name to be more descriptive 
changeDescriptiveName <- function(featureName) {
        #substitue text "(" and ")" to empty string
        descName <- gsub("[\\(\\)]","", featureName)
        #substitue text non(a-zA-Z0-9) to "_"
        descName <- gsub("[^(a-zA-Z0-9)]",".", descName)
        #lower case the feature name
        descName <- tolower(descName)
}

mergeData <- function() {
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
        return (trainData)
        
}

#use shape2 library to melt merge data 
#group by Subject , Activity, Measurement
#Summaryize value with Mean(value)
#arrange by subject , activity
getTidyData <- function(mergeData) {
        #use  reshape2 to melt data.table to subject, activity, variable, value
        meltData <- melt(mergeData, id=c("subject","activity"),
                         measure.vars=names(mergeData)[3:length(names(mergeData))]) 
        #set descriptive column names 
        meltData <- setNames(meltData, c("subject","activity","measurement", "value"))
        #use dplyr to summarize mean for each subject,activity, measurement
        tidyData <- meltData %>%  
                #group by subject,activity, measurement
                group_by(subject,activity, measurement)  %>%
                #summarise by mean for each value
                summarise(mean = mean(value)) %>%
                arrange(subject, activity)
        
        return (tidyData)
}
