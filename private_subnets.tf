resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.base.id
  count             = length(var.availability_zones)
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.availability_zones) + var.private_subnets_offset)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name                 = "private-subnet-${var.component}-${var.deployment_identifier}-${element(var.availability_zones, count.index)}"
    Component            = var.component
    DeploymentIdentifier = var.deployment_identifier
    Tier                 = "private"
  }
}

resource "aws_subnet" "private_secondary" {
  vpc_id            = aws_vpc.base.id
  count             = length(var.secondary_subnets)
  cidr_block        = var.secondary_subnets[count.index]
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name                 = "private-secondary-subnet-${var.component}-${var.deployment_identifier}-${element(var.availability_zones, count.index)}"
    Component            = var.component
    DeploymentIdentifier = var.deployment_identifier
    Tier                 = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.base.id

  tags = {
    Name                 = "private-routetable-${var.component}-${var.deployment_identifier}"
    Component            = var.component
    DeploymentIdentifier = var.deployment_identifier
    Tier                 = "private"
  }
}

resource "aws_route" "private_internet" {
  count                  = var.include_nat_gateway == "yes" ? 1 : 0
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = element(aws_nat_gateway.base.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_secondary" {
  count          = length(aws_subnet.private_secondary)
  subnet_id      = aws_subnet.private_secondary[count.index].id
  route_table_id = aws_route_table.private.id
}
