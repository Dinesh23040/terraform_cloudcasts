#gateways.tf

#IGW
resource "aws_internet_gateway" "igw" {

	vpc_id=aws_vpc.vpc.id
	
	tags={
				Name ="cloudcasts-${var.infra_env}-vpc"
                Project = "cloudcasts.io"
                Environment =var.infra_env
                VPC=aws_vpc.vpc.id
				ManagedBy ="terraform"				
	}

}

#Nat gateway (NGW)

resource "aws_eip" "nat" {
	vpc=true
	
	lifecycle {
		#prevent_destroy=true
	}
	
	tags={
				Name ="cloudcasts-${var.infra_env}-vpc"
                Project = "cloudcasts.io"
                Environment =var.infra_env
                VPC=aws_vpc.vpc.id
				ManagedBy ="terraform"	
				Role="private"
		
	}
}


resource "aws_nat_gateway" "ngw" {

	allocation_id=aws_eip.nat.id
	
	
	#whichever the first public subnet happens to be
	#(because NGW needs to be on a public subnet with an IGW)
	# Keys() : link
	#element() : link
	subnet_id=aws_subnet.public[element(keys(aws_subnet.public),0)].id
	
	
	
	tags={
				Name ="cloudcasts-${var.infra_env}-vpc"
                Project = "cloudcasts.io"
                Environment =var.infra_env
                VPC=aws_vpc.vpc.id
				ManagedBy ="terraform"	
				Role="private"
	}
	
}



#Route Tables and route


# public Route table (Subnets with IGW)

resource "aws_route_table" "public" {
	vpc_id=aws_vpc.vpc.id
	
	tags={
		Name ="cloudcasts-${var.infra_env}-vpc"
                Project = "cloudcasts.io"
                Environment =var.infra_env
                VPC=aws_vpc.vpc.id
		ManagedBy ="terraform"	
		Role="public"
	}

}

# private Route table (Subnets without IGW connection)

resource "aws_route_table" "public" {
	vpc_id=aws_vpc.vpc.id
	
	tags={
		Name ="cloudcasts-${var.infra_env}-vpc"
                Project = "cloudcasts.io"
                Environment =var.infra_env
                VPC=aws_vpc.vpc.id
		ManagedBy ="terraform"	
		Role="private"
	}

}


#public route

resource "aws_route" "public" {

	route_table_id = aws_route_table.public.id
	destination_cidr_block="0.0.0.0/0"
	gateway_id=aws_internet_gateway.igw.id

}


#private route

resource "aws_route" "private" {

	route_table_id = aws_route_table.private.id
	destination_cidr_block="0.0.0.0/0"
	nat_gateway_id=aws_nat_gateway.ngw.id

}

# Public route to public Route Table for public subnets
resource "aws_route_table_association" "public" {

	for_each=aws_subnet.public
	subnet_id=aws_subnet.public[each.key].id
	
	route_table_id=aws_route_table.public.id


}

# Public route to public Route Table for public subnets
resource "aws_route_table_association" "private" {

	for_each=aws_subnet.private
	subnet_id=aws_subnet.private[each.key].id
	
	route_table_id=aws_route_table.private.id


}





















