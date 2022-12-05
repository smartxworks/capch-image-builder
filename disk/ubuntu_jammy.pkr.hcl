packer {
  required_version = ">= 1.8.0"

  required_plugins {
    qemu = {
      version = "= 1.0.7"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = "= 1.0.3"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "arch" {
  type = string
}

variable "firmware" {
  type = string
}

variable "qemu_binary" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "cpu_type" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "sudo_password" {
  type      = string
  sensitive = true
}

source "qemu" "ubuntu_jammy" {
  iso_url        = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-${var.arch}.img"
  iso_checksum   = "file:https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS"
  disk_image     = true
  disk_size      = "8G"
  format         = "qcow2"
  disk_interface = "virtio"
  firmware       = var.firmware
  use_pflash     = true
  qemu_binary    = var.qemu_binary
  machine_type   = var.machine_type
  qemuargs = [
    ["-cpu", "${var.cpu_type}"],
    ["-device", "virtio-rng-pci,rng=rng0"],
    ["-object", "rng-random,filename=/dev/urandom,id=rng0"]
  ]
  headless         = true
  memory           = 1024
  net_device       = "virtio-net"
  output_directory = "ubuntu_jammy"
  vm_name          = "disk.img"
  cd_content = {
    "meta-data" = ""
    "user-data" = "#cloud-config\npassword: ${var.sudo_password}\nchpasswd: { expire: False }\nssh_pwauth: True"
  }
  cd_label         = "cidata"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  ssh_username     = "ubuntu"
  ssh_password     = var.sudo_password
  ssh_timeout      = "30m"
  disable_vnc      = true
}

build {
  sources = ["source.qemu.ubuntu_jammy"]

  provisioner "shell" {
    inline = ["sudo cloud-init clean --logs"]
  }

  provisioner "ansible" {
    user            = "ubuntu"
    playbook_file   = "./playbook.yml"
    extra_arguments = ["--extra-vars", "KUBERNETES_VERSION=${var.kubernetes_version}"]
    ansible_env_vars = [
      "ANSIBLE_SSH_ARGS='-o PubkeyAcceptedKeyTypes=+ssh-rsa -o HostkeyAlgorithms=+ssh-rsa'"
    ]
  }
}
