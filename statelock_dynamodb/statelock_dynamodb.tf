#just added lifecyle in aws_instance resource and hardcoded ami

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.54.0"
    }
  }

backend "s3"{

	bucket="terraformremotestate1"
	key="cloudcasts/terraform.tfstate"
	profile = "default"
        region  = "ap-south-1"
	dynamodb_table="cloudcasts-terraform-course"
	
	}
}

provider aws {
  profile = "default"
  region  = "ap-south-1"
}

variable "infra_env"{
        type=string
        description ="infrastructure environment"
}

variable default_region {

        type=string
        description="the region this infrastructure is in"
        default="ap-south-1"
}


variable instance_size{
        type=string
        description="ec2 web server size"
        default="t2.small"
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

resource "aws_instance" "cloudcasts_web" {

  ami           = data.aws_ami.app.id
  instance_type = var.instance_size

  root_block_device {

    volume_size = 8 #GB
    volume_type = "gp2"

  }

        lifecycle {

                create_before_destroy = true
        }


        tags ={
                Name ="cloudcasting-${var.infra_env}-web-address"
                Project ="cloudcasts.io"
                Environment =var.infra_env
                ManagedBy ="terraform"
		Foo="whatever-dynamodb-table"
        }

}



resource "aws_eip" "app_eip"{
        #instance=aws_instance.cloudcasts_web.id
        vpc =true

        #lifecycle{
        #prevent_destroy=true
        #}


        tags= {
                Name ="cloudcasting-${var.infra_env}-web-address"
                Project ="cloudcasts.io"
                Environment =var.infra_env
                ManagedBy ="terraform"
        }

}


resource "aws_eip_association" "app_eip_assoc" {
  instance_id   = aws_instance.cloudcasts_web.id
  allocation_id = aws_eip.app_eip.allocation_id
}

#========================================================================

#file : variables.tfvars

#infra_env="staging"
#instance_size="t2.micro"

#command : #terraform plan -var-file variables.tfvars



