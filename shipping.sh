#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

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

dnf install maven -y &>>$LOGFILE
VALIDATE $? "Installing maven"

id roboshop &>>$LOGFILE
if [ $? -ne 0 ]
then
    echo -e "$Y Warning:: roboshop user is not present, creating user...
$N"
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Adding roboshop user"          
else                                
    echo -e "$Y roboshop user already exists $Yskipping... $N"
fi     
mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating /app directory"

curl -L -o /tmp/shipping.zip "https://roboshop-artifacts.s3.amazonaws.com/shipping.zip" &>>$LOGFILE
VALIDATE $? "Downloading shipping code"

cd /app &>>$LOGFILE
VALIDATE $? "Changing directory to /app"

unzip -o /tmp/shipping.zip &>>$LOGFILE
VALIDATE $? "Extracting shipping code"

cd /app &>>$LOGFILE
VALIDATE $? "Changing directory to /app"

mvn clean package &>>$LOGFILE
VALIDATE $? "Building shipping code"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE
VALIDATE $? "Renaming shipping jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
VALIDATE $? "Copying shipping systemd service file"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading systemd daemon"

systemctl enable shipping &>>$LOGFILE
VALIDATE $? "Enabling shipping service"

systemctl start shipping &>>$LOGFILE
VALIDATE $? "Starting shipping service"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql client"

mysql -h mysql.opsora.space -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE
VALIDATE $? "Creating shipping database schema"

systemctl restart shipping
VALIDATE $? "Restarting shipping service"