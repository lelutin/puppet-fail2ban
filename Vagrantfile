# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian-9-amd64"

  # If you don't have this plugin, the puppet provisioning will most likely
  # fail. You can fix that by manually downloading the puppet module
  # dependencies of this plugin and placing them in tests/modules/
  if Vagrant.has_plugin?("vagrant-librarian-puppet")
    config.librarian_puppet.puppetfile_dir = "tests"
    config.librarian_puppet.destructive = false
  end

  config.vm.define :test do |test|
    test.vm.provision "shell", inline: "apt-get update"

    test.vm.provision :puppet do |puppet|
      puppet.manifests_path = "tests"
      puppet.manifest_file = "init.pp"
      puppet.module_path = "tests/modules"
    end
  end
end
