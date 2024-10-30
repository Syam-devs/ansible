#!/bin/bash

AMI=ami-0b4f379183e5706b9
SG_ID=sg-0e4b83efbf93fa4e7
INSTANCES=("mongodb" "redis" "mysql" "rabbit" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
ZONE_ID=Z0068375Z0TI8GQHGWMT
DOMAIN_NAME=devtechy.fun

for i in "${INSTANCES[@]}"
do
    if [ "$i" = "mongodb" ] || [ "$i" = "mysql" ] || [ "$i" = "shipping" ]
    then 
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances \
        --image-id $AMI \
        --count 1 \
        --instance-type $INSTANCE_TYPE \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${i}}]" \
        --query "Instances[0].PublicIpAddress" \
        --output text)

    echo "$i: $IP_ADDRESS"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch "{
      \"Comment\": \"Creating a record for $i endpoint\",
      \"Changes\": [
        {
          \"Action\": \"CREATE\",
          \"ResourceRecordSet\": {
            \"Name\": \"$i.$DOMAIN_NAME\",
            \"Type\": \"A\",
            \"TTL\": 60,
            \"ResourceRecords\": [
              {
                \"Value\": \"$IP_ADDRESS\"
              }
            ]
          }
        }
      ]
    }"
done
