#!/bin/bash

# Specify your VPC name
VPC_NAME="eksctl-eksworkshop-VPC"

# Fetch the VPC ID based on the VPC name
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --query "Vpcs[].VpcId" --output text)

if [ -z "$VPC_ID" ]; then
  echo "No VPC found with the name $VPC_NAME"
  exit 1
fi

echo "VPC ID for $VPC_NAME is $VPC_ID"

# Fetch Elastic IPs associated with NAT Gateways in the specified VPC
NAT_GATEWAY_EIPS=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query "NatGateways[].NatGatewayAddresses[].AllocationId" --output text)

# Fetch Elastic IPs associated with EC2 Instances in the specified VPC
INSTANCE_EIPS=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" "Name=instance-state-name,Values=running,stopped" --query "Reservations[].Instances[].NetworkInterfaces[].Association.AllocationId" --output text)

# Combine all EIP allocation IDs
ALL_EIPS="$NAT_GATEWAY_EIPS $INSTANCE_EIPS"

if [ -z "$ALL_EIPS" ]; then
  echo "No Elastic IPs found in VPC $VPC_NAME"
  exit 0
fi
