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

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing default Nginx content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOGFILE
VALIDATE $? "Downloading web content"

cd /usr/share/nginx/html &>>$LOGFILE
VALIDATE $? "Changing directory to Nginx html"

unzip /tmp/web.zip &>>$LOGFILE
VALIDATE $? "Extracting web content"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$LOGFILE
VALIDATE $? "Copying roboshop nginx config file"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting Nginx"

