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

dnf install python36 gcc python3-devel -y &>>$LOGFILE
VALIDATE $? "Installing python3.6"

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE
VALIDATE $? "Downloading payment code"

cd /app &>>$LOGFILE
VALIDATE $? "Changing directory to /app"
unzip -o /tmp/payment.zip &>>$LOGFILE
VALIDATE $? "Extracting payment code"
cd /app &>>$LOGFILE
VALIDATE $? "Changing directory to /app"
pip3.6 install -r requirements.txt &>>$LOGFILE
VALIDATE $? "Installing python dependencies"
cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
VALIDATE $? "Copying payment systemd service file"
systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Reloading systemd daemon"
systemctl enable payment &>>$LOGFILE
VALIDATE $? "Enabling payment service"
systemctl start payment &>>$LOGFILE
VALIDATE $? "Starting payment service"
