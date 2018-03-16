variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "aws_access_key" {
  description = "AWS access key"
  default = ""
}

variable "aws_secret_key" {
  description = "AWS secret key"
  default = ""
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-west-1"
}

# Red Hat Enterprise Linux 7.4
variable "aws_amis" {
  default = {
    us-west-1 = "ami-77a2a317"
  }
}
