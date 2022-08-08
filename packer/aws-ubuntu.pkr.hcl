source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_name}-${formatdate("MM-DD-YYYY", timestamp())}-${substr(uuidv4(), 0, 4)}"
  instance_type = "${var.instance_type}"
  region        = "${var.region}"
  source_ami_filter {
    filters = {
      name                = "${var.name}"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  ssh_password = "temp-password"
  user_data_file = "/usr/src/app/packer/user_data.sh"
  
}


build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    script = "/usr/src/app/ansible/ansible.sh"
  }

  
  provisioner "ansible-local" {
    playbook_file    = "/usr/src/app/ansible/playbook.yaml"
    role_paths       = ["/usr/src/app/ansible_collections/devsec/hardening/roles/os_hardening","/usr/src/app/ansible/roles/geerlingguy.docker","/usr/src/app/ansible/roles/geerlingguy.kubernetes"]
    #### THIS SHOULD WORK - BUT IT IS NOT 
    #collection_paths = ["./ansible_collections/"]
    staging_directory = "."
  }
}


