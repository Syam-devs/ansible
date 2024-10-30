#!/bin/bash

AMI=ami-0b4f379183e5706b9
SG_ID=sg-0e4b83efbf93fa4e7
INSTANCE_TYPE=("mongodb" "redis" "mysql" "rabbit" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
ZONE_ID=Z0068375Z0TI8GQHGWMT
DOMAIN_NAME=devtechy.fun

for i in "${INSTANCES[@]}"
DO
    if [ $i == "mongodb" ] || [ $i == "mysql"] || [ $i == "shipping" ]
    then 
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    aws ec2 run-instances --image-id ami-0b4f379183e5706b9 --count 1 --instance-type t2.micro --security-group-ids sg-0e4b83efbf93fa4e7


    IP_ADRESS=$( aws ec2 run-instances --image-id $ami --instance-type $INSTANCE_TYPE --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${i}}]" --query "Instances[0].PublicIpAddress" --output text )
    echo "$i: $IP_ADRESS"

aws route53 change-resource-record-sets \
--hosted-zone-id $ZONE_ID \ 
--change-batch '
{
    "comment"="Creating a record for cognito endpoint",
    ,"changes"= [{
    "Action" : "create"
    ,"ResourceRecords" : {
        "Name" : "'$i'.'$DOMAIN_NAME'"
        ,"Type" : "A"
        ,"TTL" : 1
        ,"ResourceRecords" : [{
        "ResourceValue" : "'$IP_ADRESS'"
        }]
    }
    }]
}
'
done
