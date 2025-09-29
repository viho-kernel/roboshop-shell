#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"  
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

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
dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling Nodejs module"
dnf module enable nodejs:18 -y &>>$LOGFILE
VALIDATE $? "Enabling Nodejs 18 module"
dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Nodejs"
id roboshop &>>$LOGFILE
if [ $? -ne 0 ]
then
    echo -e "$Y Warning:: roboshop user is not present, creating user...$N"
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "$Y roboshop user already exists $Yskipping... $N"
fi  

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating /app directory"   
curl -L -o /tmp/cart.zip "https://roboshop-artifacts.s3.amazonaws.com/cart.zip" &>>$LOGFILE
VALIDATE $? "Downloading cart code"
cd /app &>>$LOGFILE     
VALIDATE $? "Changing directory to /app"
unzip -o /tmp/cart.zip &>>$LOGFILE
VALIDATE $? "Extracting cart code"
cd /app &>>$LOGFILE
VALIDATE $? "Changing directory to /app"
npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"    
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>>$LOGFILE
VALIDATE $? "Copying cart systemd service file"
systemctl daemon-reload &>>$LOGFILE 
VALIDATE $? "Reloading systemd daemon"
systemctl enable cart &>>$LOGFILE
VALIDATE $? "Enabling cart"
systemctl start cart &>>$LOGFILE
VALIDATE $? "Starting cart"
