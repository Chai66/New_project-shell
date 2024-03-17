#!/bin/bash

VAR_1=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
#MONGODB_HOST:172.31.9.214

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ... $R FAILED $N"
    else 
        echo -e "$2 ... $G SUCCESS $N"
    fi
}


    if [ $VAR_1 -ne 0 ]
    then 
        echo -e "$R ERROR: Please run scrit with root access $N"
        exit 1 # you can give other than zero
    else
        echo -e " $G You Are a root user  $N"
    fi

 dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Diasbling current Nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling Nodejs:18"

 dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing Nodejs:18"

useradd roboshop &>> $LOGFILE

VALIDATE $? "creating roboshop user" 

mkdir /app

VALIDATE $? "creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading catalogue Application" 

cd /app

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unzipping catalogue" 

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencies" 

# use absolute path, becasue catalogue.service exist in that location
cp /home/centos/roboshop-project/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "Copying catalogue.service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue daemon reload" 

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enabling catalogue" 

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Catalogue starting" 

 cp /home/centos/roboshop-project/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying mongodb repo" 

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing Mongodb client" 

mongo --host 172.31.9.214 </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "loading catalogue data into Mongodb"


