# Worker node definitions

# Worker node AMI
data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.demo.version}-v*"]
  }

  most_recent = true
  owners      = ["amazon"]
}

# Launch configuration for worker node autoscaling group
locals {
  demo-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.demo.endpoint}' --b64-cluster-ca '${aws_eks_cluster.demo.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "demo" {
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.demo-node.name}"
  image_id = "${data.aws_ami.eks-worker.id}"
  instance_type = var.instance-type
  name_prefix = var.cluster-name
  security_groups = ["${aws_security_group.demo-node.id}"]
  user_data_base64 = "${base64encode(local.demo-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

# Worker node autoscaling group

resource "aws_autoscaling_group" "demo" {

  desired_capacity = var.cluster-size
  launch_configuration = "${aws_launch_configuration.demo.id}"
  max_size = var.max-size
  min_size = var.min-size
  name = var.cluster-name
  vpc_zone_identifier = "${aws_subnet.demo.*.id}"

  tag {
    key = "Name"
    value = "${var.cluster-name}"
    propagate_at_launch = true
  }

  tag {
    key = "kubernetes.io/cluster/${var.cluster-name}"
    value = "owned"
    propagate_at_launch = true
  }
}
