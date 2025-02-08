#!/bin/bash
VPC_NAME=eksctl-eksworkshop-VPC
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --query "Vpcs[].VpcId" --output text)
NAT_GATEWAY_IDS=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query "NatGateways[].NatGatewayId" --output text)
for NAT_GATEWAY_ID in $NAT_GATEWAY_IDS; do
  aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GATEWAY_ID
done
