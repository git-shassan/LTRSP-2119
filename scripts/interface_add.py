import boto3
ec2 = boto3.resource('ec2')
client = boto3.client('ec2')
EC2_KEY="Name"
EC2_VALUE="awsocp-*-master-0"
SG_VALUE="xrd-terraform-*-data"
SUB_KEY="Name"
SUB_VALUE="xrd-terraform-*-trunk-1"

## Get EC2 instance ID:
custom_filter = [{'Name':'tag:Name','Values': [EC2_VALUE]}]
response = client.describe_instances(Filters=custom_filter)
#response['Reservations'][0]['Instances'][0]['InstanceId']
EC2_ID=response['Reservations'][0]['Instances'][0]['InstanceId']

## Get SG ID:
custom_sg_filter = [{'Name':'group-name','Values': [SG_VALUE]}]
response_sg = client.describe_security_groups(Filters=custom_sg_filter)
response_sg['SecurityGroups'][0]['GroupId']
SG_ID=response_sg['SecurityGroups'][0]['GroupId']

## Get Subnet ID:
custom_sub_filter = [{'Name':'tag:Name','Values': [SUB_VALUE]}]
response_sub = client.describe_subnets(Filters=custom_sub_filter)
response_sub['Subnets'][0]['SubnetId']
SUB_ID=response_sub['Subnets'][0]['SubnetId']

## Create Interface:
response_intf = client.create_network_interface(
    SubnetId=SUB_ID,
    Description="Second Interface",
    Groups=[SG_ID]
)
NET_ID=response_intf['NetworkInterface']['NetworkInterfaceId']
#NET_ID

## Attach interface: 
response = client.attach_network_interface(
    NetworkInterfaceId=NET_ID,
    InstanceId=EC2_ID,
    DeviceIndex=1
)
