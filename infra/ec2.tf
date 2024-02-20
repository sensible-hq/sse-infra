resource "aws_instance" "ec2" {
  count = 2

  ami           = "ami-03cceb19496c25679"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  subnet_id              = aws_subnet.public_subnet[count.index].id
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name = "${var.stage}-instance-${count.index}"
  }

  user_data = file("ec2_init.sh")
}
