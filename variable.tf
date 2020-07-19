variable "wordpress_ami" {
    type = string
    description = "AMI ID of WordPress"
    default = "ami-000cbce3e1b899ebd"
}
variable "mysql_ami" {
    type = string
    description = "AMI ID of MySQL"
    default = "ami-0019ac6129392a0f2"
}
variable "instance_type" {
    type = string
    description = "Instance Type Of AWS"
    default = "t2.micro"
}
variable "Key_Name" {
    type = string
    description = "Key Name For Instance"
    default = "Terraform"
}

