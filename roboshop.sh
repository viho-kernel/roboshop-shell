#!/bin/bash

AMI=ami-0b4f379183e5706b9
SG_ID=sg-00efbfec6ad5ec04a
INSTANCES=("mongodb" "redis" "rabbitmq" "mysql" "catalogue" "user" "cart" "shipping" "payment" "frontend" "dispatch" "web")

for i in "${INSTANCES[@]}"
do
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    aws ec2 run-instances --image-id ami-0b4f379183e5706b9 --instance-type $INSTANCE_TYPE --security-group-ids sg-00efbfec6ad5ec04a --tag-specifications "ResourceType=instance,Tags=[{Key=stack,Value=$i}]"

done