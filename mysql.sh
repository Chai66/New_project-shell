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

    dnf module disable mysql -y &>> $LOGFILE

    VALIDATE $? "disabling existing mysql version"

cp /home/centos/New_project-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "Copied mysql repo"

dnf install mysql-community-server -y  &>> $LOGFILE

VALIDATE $? "Installing mysql"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "mysql Enabled"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "setting root password"

mysql -uroot -pRoboShop@1 &>> $LOGFILE

VALIDATE $? "chhecking username" &>> $LOGFILE
