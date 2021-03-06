resource "null_resource" "provisioner" {

  triggers {
    instance_id = "${join(",", aws_instance.ubuntu16.*.id)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'waiting for dpkg lock to clear...'; sleep 30",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get -y install linux-generic-hwe-16.04 linux-cloud-tools-generic-hwe-16.04",
      "sudo apt-get -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade -y",
      "sudo apt-get update",
      "#echo 'adding docker repository'",
      "#sudo add-apt-repository -y \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "#echo 'adding java repository'",
      "#sudo apt-add-repository -y ppa:webupd8team/java",
      "#echo 'debconf shared/accepted-oracle-license-v1-1 select true'| sudo debconf-set-selections",
      "#echo 'adding ansible repository'",
      "#sudo apt-add-repository -y ppa:ansible/ansible",
      "echo 'adding gitlab repo'",
      "curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash",
      "echo 'updating repositories before installation'",
      "sudo apt-get update",
      "#echo 'installing docker'",
      "#sudo apt-get install -y docker-ce && docker -v",
      "#sudo curl -o /usr/local/bin/docker-compose -L \"https://github.com/docker/compose/releases/download/1.15.0/docker-compose-$(uname -s)-$(uname -m)\"",
      "#sudo chmod +x /usr/local/bin/docker-compose && docker-compose -v",
      "#echo 'installing java'",
      "#sudo apt-get install -y oracle-java8-installer",
      "#echo 'installing ansible'",
      "#sudo apt-get install -y ansible",
      "echo 'installing postfix'",
      "sudo apt-get install -y postfix",
      "echo 'installing gitlab'",
      "sudo EXTERNAL_URL='http://${element(aws_instance.ubuntu16.*.public_dns, count.index)}' apt-get install -y gitlab-ee"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      host = "${element(aws_instance.ubuntu16.*.public_dns, count.index)}"
    }

  }

  count = "${var.inst_count}"

}
