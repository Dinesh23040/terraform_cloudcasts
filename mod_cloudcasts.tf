terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.54.0"
    }
  }
}
backend "s3"{

	bucket="terraformremotestate1"
	key="cloudcasts/terraform.tfstate"
	profile = "default"
        region  = "ap-south-1"
	dynamodb_table="cloudcasts-terraform-course"
	
}


provider aws {
  profile = "default"
  region  = "ap-south-1"
}


data "aws_ami" "app" {
  most_recent = true

  filter {
    name   = "tag:Name"
    values = ["ansiblenode_terraform_AMI"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {

    name   = "tag:environment"
    values = [var.infra_env]
  }

  filter {

    name   = "architecture"
    values = ["x86_64"]
  }



  owners = ["900390405940"] # canonical official id
}


module "ec2_app" {
	source="./modules/ec2"
	infra_env=var.infra_env
	infra_role="web"
	instance_size="t2.small"

	instance_ami=data.aws_ami.app.id
	subnets =keys(module.vpc.vpc_public_subnets)
	security_groups=[module.vpc.security_group_public]

	
	tags {
	 Name = "cloudcasting-${var.infra_env}-web"
	
	}
	create_eip=true

}


module "ec2_worker" {
	source="./modules/ec2"
	infra_env=var.infra_env
	infra_role="worker"
	#instance_size="t3.large"
	instance_size="t2.small"

	instance_ami=data.aws_ami.app.id

	#instance_root_device_size=20

	subnets =keys(module.vpc.vpc_private_subnets)
	
	security_groups=[module.vpc.security_group_private]

	tags {
	 Name = "cloudcasting-${var.infra_env}-worker"
	
	}
	create_eip=false

}

