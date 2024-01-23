resource "aws_s3_object" "folder1" {
  bucket = "datadeft-tf-dev"
  key    = "test"
  source = "/dev/null"
}
