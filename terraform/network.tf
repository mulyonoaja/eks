# Get all availibility zones
data "aws_availability_zones" "available" {}

# VPC definitions
resource "aws_vpc" "demo" {
  cidr_block = var.vpc-cidr

  tags = "${
    map(
      "Name", "${var.cluster-name}-vpc",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

# Subnet definitions
resource "aws_subnet" "demo" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index + 1}.0/24"
  vpc_id            = "${aws_vpc.demo.id}"

  tags = "${
    map(
      "Name", "${var.cluster-name}-subnet${count.index + 1}",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

# Internet gateway definitions
resource "aws_internet_gateway" "demo" {
  vpc_id = "${aws_vpc.demo.id}"
  tags = {
    Name = "${var.cluster-name}-igw"
  }
}

# Route table definitions
resource "aws_route_table" "demo" {
  vpc_id = "${aws_vpc.demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demo.id}"
  }
}

resource "aws_route_table_association" "demo" {
  count = 2

  subnet_id      = "${aws_subnet.demo.*.id[count.index]}"
  route_table_id = "${aws_route_table.demo.id}"
}

# Master node security groups definitions
resource "aws_security_group" "demo-cluster" {
  name        = "esk-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.demo.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "esk-demo-node"
  }
}

# Allow inbound traffic from local workstation's external IP to Kubernetes cluster.
resource "aws_security_group_rule" "demo-cluster-worstation-ingress-https" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  description       = "Allow workstation to communicate with Cluster API server"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.demo-cluster.id}"
  type              = "ingress"
}

# Worker node security group definitions
resource "aws_security_group" "demo-node" {
  name        = "esk-demo-node"
  description = "Security groups for worker nodes in the cluster"
  vpc_id      = "${aws_vpc.demo.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
      "Name", "${var.cluster-name}-node",
      "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "demo-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.demo-node.id}"
  source_security_group_id = "${aws_security_group.demo-node.id}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with cluster API server"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.demo-cluster.id}"
  source_security_group_id = "${aws_security_group.demo-node.id}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.demo-node.id}"
  source_security_group_id = "${aws_security_group.demo-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}
