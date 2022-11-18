data "terraform_remote_state" "level1" {
  backend = "s3"

  config = {
    bucket = "tf-state-hubert132487863"
    key    = "level1.tfstate"
    region = "eu-west-2"
  }
}
