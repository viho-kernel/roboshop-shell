#!/bin/bash

AMI=ami-0b4f379183e5706b9
SG_ID=sg-00efbfec6ad5ec04a
HOSTED_ZONE_ID=Z00411723OW0TZNO90WFS
INSTANCES=("mongodb" "redis" "rabbitmq" "mysql" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

for i in "${INSTANCES[@]}"
do
    echo "Checking instance: $i"

    # Check if instance already exists
    EXISTING_INSTANCE=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$i" "Name=instance-state-name,Values=running,pending" \
        --query 'Reservations[*].Instances[*].InstanceId' --output text)

    if [ -n "$EXISTING_INSTANCE" ]; then
        echo "$i already exists with Instance ID: $EXISTING_INSTANCE"
        continue
    fi

    # Choose instance type
    if [ "$i" == "mongodb" ] || [ "$i" == "mysql" ] || [ "$i" == "shipping" ]; then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t3.micro"
    fi

    # Launch instance
    IP_address=$(aws ec2 run-instances \
        --image-id $AMI \
        --instance-type $INSTANCE_TYPE \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" \
        --query 'Instances[0].PrivateIpAddress' \
        --output text)

    echo "Private IP of $i: $IP_address"

    # Create DNS record
    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '{
      "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$i'.opsora.space",
          "Type": "A",
          "TTL": 300,
          "ResourceRecords": [{"Value": "'$IP_address'"}]
        }
      }]
    }'

    echo "✅ Created DNS record for $i.opsora.space pointing to $IP_address"
done