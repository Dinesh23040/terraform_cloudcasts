#main.tf


resource "aws_vpc" "vpc"{
	cidr_block=var.vpc_cidr
	
	tags={
			Name ="cloudcasting-${var.infra_env}-web-address"                
			Project = "cloudcasts.io"
			Environment =var.infra_env
			ManagedBy ="terraform"
	}
}

resource "aws_subnet" "public"{
	
	for_each=var.public_subnet_numbers
	
	cidr_block=""
	vpc_id=aws_vpc.vpc.id
	cidr_block=cidrsubnet(aws_vpc.vpc.cidr_block, 4 , each.value)
	
	tags={
	
				Name ="cloudcasting-${var.infra_env}-public-subnet"
                Role ="public"
				Project = "cloudcasts.io"
                Environment =var.infra_env
                ManagedBy ="terraform"
				subnet="${each.key}-${each.value}"
				
	}
	
}


resource "aws_subnet" "private"{
	
	for_each=var.private_subnet_numbers
	
	cidr_block=""
	vpc_id=aws_vpc.vpc.id
	cidr_block=cidrsubnet(aws_vpc.vpc.cidr_block, 4 , each.value)
	
	tags={
	
				Name ="cloudcasting-${var.infra_env}-private-subnet"
                Role ="private"
				Project = "cloudcasts.io"
                Environment =var.infra_env
                ManagedBy ="terraform"
				subnet="${each.key}-${each.value}"
				
	}
	
}
