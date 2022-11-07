terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "eu-west-2"
}

resource "aws_security_group" "EC2SecurityGroup" {
    description = "SSH_Template"
    name = "SSH_Template"

    vpc_id = "${aws_vpc.EC2VPC.id}"
    ingress {
        cidr_blocks = [
            "10.0.2.0/24"
        ]
        from_port = 80
        protocol = "tcp"
        to_port = 80
    }
    ingress {
        cidr_blocks = [
            "10.0.2.0/24"
        ]
        from_port = 22
        protocol = "tcp"
        to_port = 22
    }
    ingress {
        cidr_blocks = [
            "10.0.2.0/24"
        ]
        from_port = -1
        protocol = "icmp"
        to_port = -1
    }
    egress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 0
        protocol = "-1"
        to_port = 0
    }
}

resource "aws_eip" "EC2EIP" {
    vpc = true
}

resource "aws_eip" "EC2EIP2" {
    vpc = true
}

resource "aws_vpc" "EC2VPC" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = false
    instance_tenancy = "default"

}

resource "aws_subnet" "EC2Subnet" {
    availability_zone = "eu-west-2a"
    cidr_block = "10.0.2.0/24"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = false
}

resource "aws_subnet" "EC2Subnet2" {
    availability_zone = "eu-west-2a"
    cidr_block = "10.0.1.0/24"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = false
}

resource "aws_subnet" "EC2Subnet3" {
    availability_zone = "eu-west-2a"
    cidr_block = "10.0.3.0/24"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = false
}

resource "aws_subnet" "EC2Subnet4" {
    availability_zone = "eu-west-2a"
    cidr_block = "10.0.4.0/24"
    vpc_id = "${aws_vpc.EC2VPC.id}"
    map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "EC2InternetGateway" {

    vpc_id = "${aws_vpc.EC2VPC.id}"
}

resource "aws_route" "EC2Route" {
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0d0f41d53fff0d121"
    route_table_id = "rtb-022d5b7d074cf5600"
}

resource "aws_route_table" "EC2RouteTable" {
    vpc_id = "${aws_vpc.EC2VPC.id}"

}

resource "aws_route_table" "EC2RouteTable2" {
    vpc_id = "${aws_vpc.EC2VPC.id}"

}

resource "aws_nat_gateway" "EC2NatGateway" {
    subnet_id = "subnet-0ec1d62e975b38706"

    allocation_id = "eipalloc-01e9148a0c12f5a6a"
}

resource "aws_nat_gateway" "EC2NatGateway2" {
    subnet_id = "subnet-000a9bb39918292f3"

    allocation_id = "eipalloc-08d30556b0d8740bb"
}

resource "aws_route" "EC2Route2" {
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "nat-06950c54b82a14748"
    route_table_id = "rtb-0fd6dc9e0d33893aa"
}

resource "aws_instance" "EC2Instance" {
    ami = "ami-0648ea225c13e0729"
    instance_type = "t2.micro"
    key_name = "mykp"
    availability_zone = "eu-west-2a"
    tenancy = "default"
    subnet_id = "subnet-0cb7f0bcf43c720c3"
    ebs_optimized = false
    vpc_security_group_ids = [
        "${aws_security_group.EC2SecurityGroup.id}"
    ]
    source_dest_check = true
    root_block_device {
        volume_size = 8
        volume_type = "gp2"
        delete_on_termination = true
    }

}

resource "aws_volume_attachment" "EC2VolumeAttachment" {
    volume_id = "vol-04bc0c532065790ad"
    instance_id = "i-0a75b2b3b3c4a7fd4"
    device_name = "/dev/xvda"
}

resource "aws_network_interface_attachment" "EC2NetworkInterfaceAttachment" {
    network_interface_id = "eni-0199bfdd342e69fba"
    device_index = 0
    instance_id = "i-0a75b2b3b3c4a7fd4"
}
