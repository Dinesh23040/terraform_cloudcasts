resource "random_shuffle" "subnets"{
	input=var.subnets
	result_count=1
}

resource "aws_instance" "cloudcasts_web" {

  ami           = var.instance_ami
  instance_type = var.instance_size

  root_block_device {

    volume_size =var.instance_root_device_size
    volume_type = "gp2"

  }

   subnet_id=random_shuffle.result[0] #TODO: which subnet
   vpc_security_group_ids=var.security_groups

	lifecycle{
		#create_before_destroy=true
	}
		tags =merge({
                Name ="cloudcasting-${var.infra_env}-web"
                Role =var.infra_role
		Project = "cloudcasts.io"
                Environment =var.infra_env
                ManagedBy ="terraform"
		
        },
	var.tags
	)

}



resource "aws_eip" "cloudcasts_addr"{
        
	count=(var.create_eip) ? 1 : 0	

	#we are not doing this directly

	#instance=aws_instance.cloudcasts_web.id
        vpc =true

        lifecycle{
	#prevent_destroy=true
        }


        tags= {
                Name ="cloudcasting-${var.infra_env}-web-address"
		Role=var.infra_role
                Project ="cloudcasts.io"
                Environment =var.infra_env
                ManagedBy ="terraform"
        }

}


resource "aws_eip_association" "eip_assoc" {
 

  count=(var.create_eip) ? 1 : 0	
  instance_id   = aws_instance.cloudcasts_web.id
  allocation_id = aws_eip.cloudcasts_addr[0].id

}
