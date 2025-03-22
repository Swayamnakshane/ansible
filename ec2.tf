resource "aws_key_pair" "my_key"{
    key_name = "ansible_key"
    public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxFD0lfpvwwrxjlK/6Gpxm66/XfmQqzKJlGg2mW2rzt ubuntu@ip-172-31-17-140"

}



resource "aws_default_vpc" "my_vpc"{
}
resource "aws_security_group" "my_security"{
    name = "ansible-sg"
    description = "this is inbound security"
    vpc_id = aws_default_vpc.my_vpc.id
    tags = {
        name = "ansible-sg"
        Environment = "prd"
     }
    ingress {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]


  }
    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
  }

}
resource "aws_instance" "my_instance"{
       for_each = tomap({
       master_server = "ami-0df368112825f8d8f"
       worker1       = "ami-0df368112825f8d8f"
       worker2       = "ami-0df368112825f8d8f"
   })
       depends_on = [aws_security_group.my_security,aws_key_pair.my_key]
       key_name =  aws_key_pair.my_key.key_name
       security_groups = [aws_security_group.my_security.name]
       instance_type = "t2.micro"
       ami           = each.value
       root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
  tags = {
    Name = each.key
  }
}
