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

dnf module disable mysql -y &>>$LOGFILE
VALIDATE $? "Disabling Mysql module"

cp /home/centos/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>>$LOGFILE
VALIDATE $? "Copying Mysql repo file"

dnf install mysql-community-server -y &>>$LOGFILE
VALIDATE $? "Installing Mysql"
systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling Mysql"
systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting Mysql"

mysql_secure_installation --set-root-pass RoboShop@1
mysql -uroot -pRoboShop@1 -e "show databases;" &>>$LOGFILE
VALIDATE $? "Checking Mysql connection"