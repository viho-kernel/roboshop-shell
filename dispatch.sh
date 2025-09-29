#!/bin/bash

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "script started execution at $TIMESTAMP" &>>$LOGFILE
VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$R Error:: $2 is failed.$N"
    else
        echo -e "$G Success:: $2 is successful.$N"
    fi
}

if [ $ID -ne 0 ] 
then    
  echo -e "$R Error:: This script must be run as root or with sudo.$N"
  exit 1
else
    echo -e "$G You are running this script as root.$N"

fi

dnf install golang -y &>>$LOGFILE
VALIDATE $? "Installing Golang"

useradd roboshop &>>$LOGFILE
VALIDATE $? "Adding roboshop user"

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating /app directory"
curl -L -o /tmp/dispatch.zip "https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip" &>>$LOGFILE
cd /app &>>$LOGFILE
VALIDATE $? "Changing directory to /app"
unzip -o /tmp/dispatch.zip &>>$LOGFILE
VALIDATE $? "Extracting dispatch code"
cd /app &>>$LOGFILE
VALIDATE $? "Changing directory to /app"
go mod init dispatch &>>$LOGFILE
VALIDATE $? "Initializing go module"
go get &>>$LOGFILE
VALIDATE $? "Downloading dependencies"
go build &>>$LOGFILE
VALIDATE $? "Building dispatch code"
cp /home/centos/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>>$LOGFILE
VALIDATE $? "Copying dispatch systemd service file"
systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading systemd daemon"
systemctl enable dispatch &>>$LOGFILE
VALIDATE $? "Enabling dispatch service"
systemctl start dispatch &>>$LOGFILE
VALIDATE $? "Starting dispatch service"