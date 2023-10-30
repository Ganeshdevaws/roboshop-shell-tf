#!/bin/bash

DATE=$(date +%F)
LOGDIR=/tmp
SCRIPT_NAME=$0
LOGFILE=$LOGDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\E[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum install python36 gcc python3-devel -y &>>$LOGFILE

VALIDATE $? "Installing python"

useradd roboshop &>>$LOGFILE

mkdir /app &>>$LOGFILE

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip &>>$LOGFILE

VALIDATE $? "Downloading artifacts"

cd /app &>>$LOGFILE

VALIDATE $? "Moving to app directory"

unzip /tmp/payment.zip &>>$LOGFILE

VALIDATE $? "Unzipping artifacts"

pip3.6 install -r requirements.txt &>>$LOGFILE

VALIDATE $? "Downloading dependencies"

cp /home/centos/roboshop-shell-tf/payment.service /etc/systemd/system/payment.service &>>$LOGFILE

VALIDATE $? "Coping payment service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "Daemon-reload"

systemctl enable payment &>>$LOGFILE

VALIDATE $? "Enabling payment"

systemctl start payment &>>$LOGFILE

VALIDATE $? "Starting payment"