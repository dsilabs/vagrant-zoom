# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.hostname = "zoom.dev"

  # fragile with hardcoded ip (TODO: require DNS entry on name and do a lookup)
  config.vm.network "private_network", ip: "172.28.128.250"

  config.ssh.forward_agent = true
  config.vm.synced_folder ".", "/vagrant", disabled: false

  # Provider-specific configuration so you can fine-tune various
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "4096"
  end

  # Enable provisioning with a shell script. Additional provisioners such as
    config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  config.vm.provision "shell", path: "provision.updates.sh", privileged: false
  # careful of privileged from here down
  config.vm.provision "shell", path: "provision.zoom.sh"
  config.vm.provision "shell", path: "provision.zoom.nginx.sh"
  config.vm.provision "shell", path: "provision.nginx.ssl.sh"
  # TODO: the below apache version is not yet converted/tested
  # config.vm.provision "shell", path: "provision.zoom.apache.sh"
  config.vm.provision "shell", privileged: false, inline: <<-EOF
    echo "Local server address is rebooting at https://172.28.128.250"
  EOF
  config.vm.provision "shell", inline: "sudo reboot"

end
