resource "aws_s3_bucket" "tfstate" {
  bucket = "tf-state-hubert132487863"
}

resource "aws_dynamodb_table" "tfstate" {
  name           = "tf-state"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
