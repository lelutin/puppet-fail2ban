# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  # If you don't have this plugin, the puppet provisioning will most likely
  # fail. You can fix that by manually downloading the puppet module
  # dependencies of this plugin and placing them in tests/modules/
  if Vagrant.has_plugin?('vagrant-librarian-puppet')
    config.librarian_puppet.puppetfile_dir = 'tests'
    config.librarian_puppet.destructive = false
  end

  config.vm.synced_folder ".", "/vagrant", type: "rsync",
    rsync__exclude: ".git/",
    rsync__args: ["--delete"]

  # All boxes should update, then run tests
  config.vm.provision 'shell', inline: 'apt-get update; apt-get install -y puppet-agent'
  # XXX I still have a bug with this: I need the contents of the repository to
  # be available in the modules. it can be achieved by some methods.. for now
  # my workaround is this:
  #
  #     vagrant ssh -- 'cd /tmp/vagrant-puppet/modules*/; ln -s /vagrant fail2ban'
  #     vagrant provision --provision-with puppet
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'tests'
    puppet.manifest_file = 'init.pp'
    puppet.module_path = 'tests/modules'
    puppet.synced_folder_type = 'rsync'
  end

  config.vm.define :bookworm do |bookworm|
    bookworm.vm.box = 'debian/bookworm64'
  end
end
