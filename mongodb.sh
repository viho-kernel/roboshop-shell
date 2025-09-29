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
        exit 1
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

cp mongodb.repo /etc/yum.repos.d/mongodb.repo &>>$LOGFILE
VALIDATE $? "Copying Mongodb repo file"

dnf install mongodb-org -y &>>$LOGFILE
VALIDATE $? "Installing Mongodb"

systemctl enable mongod &>>$LOGFILE
VALIDATE $? "Enabling Mongodb"

systemctl start mongod &>>$LOGFILE
VALIDATE $? "Starting Mongodb"

systemctl status mongod &>>$LOGFILE
VALIDATE $? "Checking Mongodb status"   

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGFILE
VALIDATE $? "Updating Mongodb listen address"
systemctl restart mongod &>>$LOGFILE
VALIDATE $? "Restarting Mongodb"



