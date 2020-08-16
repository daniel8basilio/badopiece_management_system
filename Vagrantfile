Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64" # Ubuntu18

  # Avoid incompatibilities when box updates.
  config.vbguest.auto_update = false
  config.vm.box_check_update = false

  # Improve vm performance.
  config.vm.provider "virtualbox" do |v|
      v.cpus = 1
      v.memory = 1024 # MB
  end

  # Network and mount configuration
  config.vm.hostname = "develop-bado.com"
  config.vm.network :private_network, ip:"192.168.33.16"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 5432, host: 5432 # PSQL
  config.vm.synced_folder ".", "/var/www/bado", :mount_options => ["dmode=777","fmode=777"]
  config.vm.synced_folder "provisioning", "/vagrant/provisioning", :mount_options => ["dmode=777","fmode=777"]

  # Use external provisioner script.
  config.vm.provision "shell", path: "provisioning/bootstrap.sh"
end
