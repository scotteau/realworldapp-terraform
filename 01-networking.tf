
################################################################################
# vpc & network
################################################################################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.default_tags, { Name = "${local.prefix}-vpc" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.default_tags, { Name = "${local.prefix}-igw" })
}

data "aws_availability_zones" "available" {}


# public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.default_tags,
  { Name = "${local.prefix}-public-${count.index + 1}" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, { Name = "${local.prefix}-route-table-public" })
}

resource "aws_route" "main" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

# private subnet
resource "aws_subnet" "private" {
  count                   = length(var.private)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.default_tags,
  { Name = "${local.prefix}-private-${count.index + 1}" })
}

# database subnet
resource "aws_subnet" "database" {
  count                   = length(var.database)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.database[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.default_tags,
  { Name = "${local.prefix}-database-${count.index + 1}" })
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.default_tags, { Name = "${local.prefix}-route-table-database" })
}

# Only for first access to seed the database initially
resource "aws_route_table_association" "database" {
  count          = length(aws_subnet.database)
  route_table_id = aws_route_table.database.id
  subnet_id      = aws_subnet.database[count.index].id
}

resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
