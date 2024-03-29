#!/bin/bash

VAR_1=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ... $R FAILED $N"
        exit 1
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

cp /home/centos/New_project-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied MongoDB repo"

dnf install mongodb-org -y  &>> $LOGFILE

VALIDATE $? "Installing Mongodb"

systemctl enable mongod

VALIDATE $? "Mongodb Enabled"

systemctl start mongod 

VALIDATE $? "Starting Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Remote Access to Mongodb"

systemctl restart mongod

VALIDATE $? "Mongodb restarted" &>> $LOGFILE
