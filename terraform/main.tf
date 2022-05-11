terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}
variable "prv_key" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}
data "digitalocean_ssh_key" "terraform" {
  name = "root"
}


# Create a web server
resource "digitalocean_droplet" "www" {
  image  = "ubuntu-20-04-x64"
  name   = "wordpress"
  region = "sfo3"
  size   = "s-1vcpu-1gb"
  ssh_keys = [ 
             data.digitalocean_ssh_key.terraform.id
             ]
  connection {
    type     = "ssh"
    user     = "root"
    host     = self.ipv4_address
    private_key = var.prv_key
  }
  
  provisioner "remote-exec" {
     inline = [
               "set -o errexit",
              #"echo 1;sudo /usr/bin/apt-get update -y --allow-unauthenticated",
              ]	
 
   }
   provisioner "local-exec" {
     command = "ansible-playbook -i ${self.ipv4_address}, /mnt/c/projects/project2/ansible/playbook.yml"
   }

}
# Create a database server
#resource "digitalocean_droplet" "www" {
#  image  = "ubuntu-18-04-x64"
#  name   = "wordpress"
#  region = "sfo3"
#  size   = "s-1vcpu-1gb"
  # ...
#}
 
  output "www" {
  description = "IP Address of droplet"
  value       = digitalocean_droplet.www.ipv4_address
}