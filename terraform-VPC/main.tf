resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.env_code
  }
}

resource "aws_subnet" "publicsub" {
  count = length(var.public_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_cidr[count.index]

  tags = {
    Name = "${var.env_code}-publicsub${count.index}"
  }
}

resource "aws_subnet" "privatesub" {
  count = length(var.private_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidr[count.index]

  tags = {
    Name = "${var.env_code}-privatesub${count.index}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.env_code
  }
}

resource "aws_eip" "nat" {
  count = length(var.public_cidr)

  vpc = true

  tags = {
    Name = "${var.env_code}-nat${count.index}"
  }
}

resource "aws_nat_gateway" "maingw" {
  count = length(var.public_cidr)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.publicsub[count.index].id

  tags = {
    Name = "${var.env_code}-maingw${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_route_table" "private" {
  count = length(var.private_cidr)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.maingw[count.index].id
  }

  tags = {
    Name = "${var.env_code}-private${count.index}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_cidr)

  subnet_id      = aws_subnet.publicsub[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_cidr)

  subnet_id      = aws_subnet.privatesub[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
