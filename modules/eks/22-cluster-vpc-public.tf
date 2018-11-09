# cluster vpc public

resource "aws_subnet" "cluster" {
  count = "${var.az_count}"

  vpc_id     = "${aws_vpc.cluster.id}"
  cidr_block = "${cidrsubnet(aws_vpc.cluster.cidr_block, 8, 20 + count.index)}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = "${
    map(
     "Name", "tf-eks-${var.name}",
     "kubernetes.io/cluster/${var.name}", "shared"
    )
  }"
}

resource "aws_internet_gateway" "cluster" {
  vpc_id = "${aws_vpc.cluster.id}"

  tags {
    Name = "tf-eks-${var.name}"
  }
}

resource "aws_route_table" "cluster" {
  vpc_id = "${aws_vpc.cluster.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.cluster.id}"
  }

  tags {
    Name = "tf-eks-${var.name}"
  }
}

resource "aws_route_table_association" "cluster" {
  count = "${var.az_count}"

  subnet_id      = "${aws_subnet.cluster.*.id[count.index]}"
  route_table_id = "${aws_route_table.cluster.id}"
}
