resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    tags = {
     Name = "main"
    }

}

resource "aws_subnet" "publicsub0" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
      tags = {
     Name = "publicsub0"
    }
}

resource "aws_subnet" "publicsub1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
     tags = {
     Name = "publicsub1"
    }
}

resource "aws_subnet" "privatesub0" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
     tags = {
     Name = "privatesub0"
    }
}

resource "aws_subnet" "privatesub1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
      tags = {
     Name = "privatesub1"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
        tags = {
     Name = "main"
    }
}

resource "aws_eip" "nat0" {
  vpc      = true
      tags = {
     Name = "nat0"
    }
}

resource "aws_eip" "nat1" {
  vpc      = true
      tags = {
     Name = "nat1"
    }
}

resource "aws_nat_gateway" "maingw0" {
  allocation_id = aws_eip.nat0.id
  subnet_id     = aws_subnet.publicsub0.id
        tags = {
     Name = "maingw0"
    }
}

resource "aws_nat_gateway" "maingw1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.publicsub1.id
        tags = {
     Name = "maingw1"
    }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
          tags = {
     Name = "public"
    }
}

resource "aws_route_table" "private0" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.maingw0.id
  }
          tags = {
     Name = "private0"
    }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.maingw1.id
  }
          tags = {
     Name = "private1"
    }
}

resource "aws_route_table_association" "public0" {
  subnet_id      = aws_subnet.publicsub0.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.publicsub1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private0" {
  subnet_id      = aws_subnet.privatesub0.id
  route_table_id = aws_route_table.private0.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.privatesub1.id
  route_table_id = aws_route_table.private1.id
}