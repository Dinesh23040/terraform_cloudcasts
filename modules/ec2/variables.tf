variable "infra_env"{
        type=string
        description ="infrastructure environment"
}

variable "infra_role"{
        type=string
        description ="infrastructure purpose"
}

variable instance_size{
        type=string
        description="ec2 web server size"
      }

variable instance_ami {

        type=string
        description="server image to use"
        
}


variable instance_root_device_size {

        type=string
        description="root block device size in GB"
	default=8 #GB        

}

variable subnets{

	type=list(string)
	description= "valid subnets to assign to server"
}


variable security_groups {
	type= list(string)
	description= "security groups to assign to server"
	default =[]

}


variable "tags" {
	type=map(string)
	default={}
	description="tags for the ec2 instance"

}


variable "create_eip"{
	type=bool
	default=false
	description="whether to create eip for ec2 instanec or not"

}



