library(plyr)
library(knitr)
#Download the zip file
if(!file.exists("./data")){
    dir.create("./data")
}
if(!file.exists("./data/Dataset.zip")){
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl,destfile="./data/Dataset.zip")
}

#Unzip the files
if(!file.exists("./data/UCI HAR Dataset")){
    unzip(zipfile="./data/Dataset.zip",exdir="./data")
}

#Reading files
path <- file.path("./data" , "UCI HAR Dataset")
activityTest <- read.table(file.path(path,"test","y_test.txt"),header=FALSE)
activityTrain <- read.table(file.path(path,"train","y_train.txt"),header=FALSE)
subjectTest <- read.table(file.path(path,"test","subject_test.txt"),header=FALSE)
subjectTrain <- read.table(file.path(path,"train","subject_train.txt"),header=FALSE)
featuresTest <- read.table(file.path(path,"test","X_test.txt"),header=FALSE)
featuresTrain <- read.table(file.path(path,"train","X_train.txt"),header=FALSE)

#Merging train and test datasets
activity <- rbind(activityTrain,activityTest)
subject <- rbind(subjectTrain,subjectTest)
features <- rbind(featuresTrain,featuresTest)

#changing datasets names
names(subject) <- c("subject")
names(activity) <- c("activity")
featuresNames <- read.table(file.path(path,"features.txt"),header=FALSE)
names(features)<- featuresNames$V2

#Mergin colums in one final data frame called data
data <- cbind(subject,activity)
data <- cbind(features,data)

#Labeling activity variable of the final data frame
activityLabel <- read.table(file.path(path,"activity_labels.txt"),header=FALSE)
data$activity <- factor(data$activity,labels=activityLabel$V2)

#Labeling the final data frame with descriptive variables names
names(data) <- gsub("^t","time",names(data)) #replace t by time
names(data) <- gsub("^f","frequency",names(data)) #replace f by frequency
names(data) <- gsub("Acc","Accelerometer",names(data)) #replace Acc by Accelerometer
names(data) <- gsub("Gyro","Gyroscope",names(data)) #replace Gyro by Giroscope
names(data) <- gsub("Mag","Magnitude",names(data)) #replace Mag by Magnitude
names(data) <- gsub("BodyBody","Body",names(data)) #replace BodyBody by Body

#Generating tidy dataset
data2 <- aggregate(. ~ subject+activity,data,mean)
data2 <- arrange(data2,subject,activity)
write.table(data2,file="tidydata.txt",row.names=FALSE)

#Codebook
knit2html("codebook.Rmd")
