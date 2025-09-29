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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash   &>>$LOGFILE
VALIDATE $? "Adding Erlang repository"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash  &>>$LOGFILE
VALIDATE $? "Adding RabbitMQ repository"

dnf install rabbitmq-server -y &>>$LOGFILE
VALIDATE $? "Installing RabbitMQ"

systemctl enable rabbitmq-server &>>$LOGFILE
VALIDATE $? "Enabling RabbitMQ"
systemctl start rabbitmq-server &>>$LOGFILE
VALIDATE $? "Starting RabbitMQ"
systemctl status rabbitmq-server &>>$LOGFILE
VALIDATE $? "Checking RabbitMQ status"
rabbitmqctl add_user roboshop roboshop123 &>>$LOGFILE
VALIDATE $? "Adding RabbitMQ user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGFILE
VALIDATE $? "Setting permissions to RabbitMQ user"