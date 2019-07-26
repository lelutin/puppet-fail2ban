# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # If you don't have this plugin, the puppet provisioning will most likely
  # fail. You can fix that by manually downloading the puppet module
  # dependencies of this plugin and placing them in tests/modules/
  if Vagrant.has_plugin?("vagrant-librarian-puppet")
    config.librarian_puppet.puppetfile_dir = "tests"
    config.librarian_puppet.destructive = false
  end

  # All boxes should update, then run tests
  config.vm.provision "shell", inline: "apt-get update"
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "tests"
    puppet.manifest_file = "init.pp"
    puppet.module_path = "tests/modules"
  end

  config.vm.define :jessie do |jessie|
    jessie.vm.box = "debian-8-amd64"
  end

  config.vm.define :stretch do |stretch|
    stretch.vm.box = "debian-9-amd64"
  end

  config.vm.define :buster do |buster|
    buster.vm.box = "debian-10-amd64"
  end
end
