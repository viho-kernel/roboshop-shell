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
    if [ $1 - ne 0 ]
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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOGFILE
VALIDATE $? "Installing Remi repository"

dnf module enable redis:remi-6.2 -y &>>$LOGFILE
VALIDATE $? "Enabling Redis 6.2 module"

dnf install redis -y &>>$LOGFILE
VALIDATE $? "Installing Redis"  

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>>$LOGFILE
VALIDATE $? "Updating Redis listen address"

systemctl enable redis &>>$LOGFILE
VALIDATE $? "Enabling Redis"

systemctl start redis &>>$LOGFILE
VALIDATE $? "Starting Redis"    
systemctl status redis &>>$LOGFILE
VALIDATE $? "Checking Redis status"

