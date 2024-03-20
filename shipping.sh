#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.devopspractice123.online

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


dnf install maven -y  &>> $LOGFILE

VALIDATE $? "Installing maven"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip  &>> $LOGFILE

VALIDATE $? "Downloading shipping application"

cd /app 

unzip /tmp/shipping.zip  &>> $LOGFILE

VALIDATE $? "unzipping shipping"

mvn clean package  &>> $LOGFILE

VALIDATE $? "Installing packages"

mv target/shipping-1.0.jar shipping.jar

VALIDATE $? "moving jar file"

# use absolute, because catalogue.service exists there
cp /home/centos/New_project-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Copying shipping service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "shipping daemon reload"

systemctl enable shipping &>> $LOGFILE

VALIDATE $? "Enable shipping"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "Starting shipping"


dnf install mysql -y &>> $LOGFILE

VALIDATE $? "Installing mysql client"

mysql -h mysql.devopspractice123.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "loading shipping data"

systemctl restart shipping

VALIDATE $? "restart shipping "


