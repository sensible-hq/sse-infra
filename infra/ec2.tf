resource "aws_instance" "ec2" {
  ami           = "ami-03cceb19496c25679"
  instance_type = "t2.micro" # TODO

  vpc_security_group_ids = [aws_security_group.sg_vpc.id]
  subnet_id              = aws_subnet.public_subnet[0].id
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  key_name = aws_key_pair.ec2_keypair.key_name

  tags = {
    Name = "sensible-test"
  }

  user_data = file("ec2_init.sh")
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance_role" {
  name               = "instance-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_policy" "instance_policy" {
  name = "instance-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLogging"
        Effect = "Allow"
        Action = [
          "logs:*"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Sid    = "AllowS3Read"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "instance_role_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.instance_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
