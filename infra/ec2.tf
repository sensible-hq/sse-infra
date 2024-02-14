resource "aws_instance" "ec2" {
  ami           = "ami-03cceb19496c25679"
  instance_type = "t2.micro" # TODO

  vpc_security_group_ids = [aws_security_group.sg_vpc.id]
  subnet_id              = aws_subnet.public_subnet[0].id

  key_name = aws_key_pair.ec2_keypair.key_name

  tags = {
    Name = "sensible-test"
  }

  user_data = file("ec2_init.sh")
}