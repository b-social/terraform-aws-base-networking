resource "aws_subnet" "private" {
  vpc_id = aws_vpc.base.id
  count = length(local.effective_availability_zones)
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + length(local.effective_availability_zones) + local.private_subnets_offset)
  availability_zone = element(local.effective_availability_zones, count.index)

  tags = {
    Name = "private-subnet-${var.component}-${var.deployment_identifier}-${element(local.effective_availability_zones, count.index)}"
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
    Tier = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.base.id
  count = length(local.effective_availability_zones)

  tags = {
    Name = "private-routetable-${var.component}-${var.deployment_identifier}-${element(local.effective_availability_zones, count.index)}"
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
    Tier = "private"
  }
}

resource "aws_route" "private_internet" {
  count = local.include_nat_gateways == "yes" ? length(local.effective_availability_zones) : 0
  route_table_id = element(aws_route_table.private.*.id, count.index)
  nat_gateway_id = element(aws_nat_gateway.base.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private" {
  count = length(local.effective_availability_zones)
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
