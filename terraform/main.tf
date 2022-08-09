resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags= {
    Name = "customvpc"
  }
}

resource "aws_subnet" "public-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/18"
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }

  #availability_zone = "us-east-2a"
  availability_zone = format("%sa", var.region)
}

resource "aws_subnet" "public-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.64.0/18"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public"
  }

  availability_zone = format("%sb", var.region)
  #availability_zone = "us-east-2b"
}



resource "aws_subnet" "private-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.128.0/18"

  tags = {
    Name = "private-1"
  }
  #availability_zone = "us-east-2c"
  availability_zone = format("%sc", var.region)
}



resource "aws_subnet" "private-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.192.0/18"

  tags = {
    Name = "private-2"
  }

  availability_zone = format("%sb", var.region)
  #availability_zone = "us-east-2b"
}



resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "customvpc-ig"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "example"
  }
}


resource "aws_route_table_association" "customvpc-public" {
  subnet_id = aws_subnet.public-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "customvpc-public-2" {
  subnet_id = aws_subnet.public-2.id
  route_table_id = aws_route_table.public.id
}





######### CREATION OF NAT #########

resource "aws_eip" "customvpc-nat" {
  vpc = true
}


resource "aws_nat_gateway" "customvpc-nat-gw" {

  allocation_id = aws_eip.customvpc-nat.id
  subnet_id     = aws_subnet.public-1.id
  depends_on    = [aws_internet_gateway.gw]
  
}

resource "aws_route_table" "customvpc-private" {

  vpc_id= aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.customvpc-nat-gw.id
  }
}


resource "aws_route_table_association" "customvpc-private-2" {
  subnet_id = aws_subnet.private-2.id
  route_table_id = aws_route_table.customvpc-private.id
}



resource "aws_route_table_association" "customvpc-private-1" {
  subnet_id = aws_subnet.private-1.id
  route_table_id = aws_route_table.customvpc-private.id
}



################################################################
###### SSH KEY CREATION ########################################

resource "tls_private_key" "tls-private" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer" 
  public_key = tls_private_key.tls-private.public_key_openssh
}

################################################################
################################################################




resource "aws_instance" "public" {

  ami = var.ami_id #"ami-036ef875352060c4e"
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.key_name
  subnet_id = aws_subnet.public-1.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.sg-publica.id]
}



resource "aws_instance" "master" {

  ami = var.ami_id #"ami-036ef875352060c4e"
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.key_name
  subnet_id = aws_subnet.private-1.id
  security_groups = [aws_security_group.sg-privada.id]
}


resource "aws_security_group" "sg-publica" {
  name        = "publica"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  
  ingress {
    from_port        = 8843
    to_port          = 8843
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "publica"
  }
}

resource "aws_security_group" "sg-privada" {
  name        = "privada"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.public-1.cidr_block]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.public-2.cidr_block]
  }

 ingress {
    from_port        = 8843
    to_port          = 8843
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.public-1.cidr_block]
  
 } 



 ingress {
    from_port        = 9443
    to_port          = 9443
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.public-1.cidr_block]
  
 } 



 ingress {
    from_port        = 9443
    to_port          = 9443
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.public-2.cidr_block]
  
 } 






 ingress {
    from_port        = 8843
    to_port          = 8843
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.public-2.cidr_block]
  
 } 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "privada"
  }
}

resource "aws_eip" "nat-ip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-ip.id
  subnet_id     = aws_subnet.public-1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

#####################################################################
### IAM ROLES FOR MASTERS ###########################################
resource "aws_iam_role" "eks-cluster" {
  name = "eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster.name
}


#########################################################
#### EKS CLUSTER ########################################

resource "aws_eks_cluster" "my-cluster" {
  name     = "my-cluster"
  role_arn = aws_iam_role.eks-cluster.arn

  vpc_config {
    subnet_ids = [aws_subnet.public-1.id,aws_subnet.public-2.id]
    security_group_ids = [aws_security_group.sg-publica.id]
    
  }


  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}




#########################################################
### WORKER NODES IAM ####################################

resource "aws_iam_role" "workernodes" {
  name = "eks-node-group-example"
 
  assume_role_policy = jsonencode({
   Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
     Service = "ec2.amazonaws.com"
    }
   }]
   Version = "2012-10-17"
  })
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.workernodes.name
 }
 
 # resource "aws_iam_role_policy_attachment" "VPC_CNI" {
 #  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 #  role    = aws_iam_role.workernodes.name
 # }



 
resource "aws_launch_template" "own-launch" {

  #image_id  = "ami-018a26bc24633bb18"

  #ami = "ami-036ef875352060c4e"
  image_id = var.ami_id
  #image_id = "ami-036ef875352060c4e"
  #image_id = "ami-09587df0398300426"
  instance_type = "t3.xlarge"
  //security_groups = [aws_security_group.sg-privada.id]
  lifecycle {
    create_before_destroy = true 
  }
  user_data = base64encode("${data.template_file.user_data.rendered}")
}



  resource "aws_eks_node_group" "worker-node-group" {
  cluster_name  = aws_eks_cluster.my-cluster.name
  node_group_name = "worker-nodes"
  node_role_arn  = aws_iam_role.workernodes.arn
  subnet_ids   = [aws_subnet.private-1.id,aws_subnet.private-2.id]
  #instance_types = ["t3.xlarge"]
 
launch_template {
   name = aws_launch_template.own-launch.name
   version = aws_launch_template.own-launch.latest_version
  }
    
  scaling_config {
   desired_size = 2
   max_size   = 3
   min_size   = 1
  }
 
  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
  }
###########################################################

 data "template_file" "user_data" {
  #template = "${file("eks.sh.tpl")}"

   template = "${file("eks.sh.tpl")}"
  vars = {
    CA = "${aws_eks_cluster.my-cluster.certificate_authority[0].data}"
    EP = "${aws_eks_cluster.my-cluster.endpoint}"
  }
}

#########################################################
### CHANGE TF.STATE DIR #################################


terraform {
  backend "local" { path = "../output/terraform.tfstate" }
}

#########################################################
### OUTPUT ##############################################

output "public_ip" {
  value = aws_instance.master.public_ip
}

output "endpoint" {
  value = aws_eks_cluster.my-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.my-cluster.certificate_authority[0].data
}

