#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
#MONGDB_HOST=mongodb.devopspilot.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "Installing python"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip

VALIDATE $? "Downloading payment application"

cd /app 

unzip /tmp/payment.zip  &>> $LOGFILE

VALIDATE $? "unzipping payment"

cd /app 

pip3.6 install -r requirements.txt  &>> $LOGFILE

VALIDATE $? "Installing dependencies"

# use absolute, because catalogue.service exists there
cp /home/centos/New_project-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "Copying payment service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "payment daemon reload"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "Enable payment"

systemctl start payment &>> $LOGFILE

VALIDATE $? "Starting payment"


