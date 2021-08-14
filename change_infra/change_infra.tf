terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.54.0"
    }
  }
}

provider "aws" {
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

    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {

    name   = "architecture"
    values = ["x86_64"]
  }



  owners = ["900390405940"] # canonical official id
}

resource "aws_instance" "cloudcasts_web" {

  ami           = data.aws_ami.app.id
  instance_type = "t2.micro"

  root_block_device {

    volume_size = 8 #GB
    volume_type = "gp2"

  }


	tags= {
		Name ="cloudcasting-staging-web"
		Project ="cloudcasts.io"
		Environment ="staging"
		ManagedBy ="terraform"	
	}

}



resource "aws_eip" "app_eip"{
	#instance=aws_instance.cloudcasts_web.id
	vpc =true
}


resource "aws_eip_association" "app_eip_assoc" {
  instance_id   = aws_instance.cloudcasts_web.id
  allocation_id = aws_eip.app_eip.id
}



