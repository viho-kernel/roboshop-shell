#!/bin/bash

AMI=ami-0b4f379183e5706b9
SG_ID=sg-00efbfec6ad5ec04a
INSTANCES=("mongodb" "redis" "rabbitmq" "mysql" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

for i in "${INSTANCES[@]}"
do
    echo "instance is: $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t3.micro"
    fi
    IP_address=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance, Tags=[{key=Name,Value=$i}]" --query 'Instances[0].PublicIpAddress' --output text)

    echo "Ip address of $i: $IP_address"

done