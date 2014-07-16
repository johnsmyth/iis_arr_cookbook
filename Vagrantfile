# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.hostname = "iis-arr"
	config.vm.guest = :windows

  config.vm.communicator = "winrm"

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "rn-w2k12r2-v1.0.0"
  #######config.vm.box = "Berkshelf-CentOS-6.3-x86_64-minimal"
  #######config.vm.box_url = "https://dl.dropbox.com/u/31081437/Berkshelf-CentOS-6.3-x86_64-minimal.box"
  #
   config.vm.provider :virtualbox do |vb, override|
     # Don't boot with headless mode
     vb.gui = true
  
     vb.customize ["modifyvm", :id, "--memory", "1024"]
     ####override.vm.box = "vagrant-win2k8r2"
     ####override.vm.box_url = ""
     override.vm.network :private_network, ip: "192.168.99.11"
		 override.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
	#	 override.omnibus.chef_version = :latest

   end

    config.winrm.timeout = 600

  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []
  #config.berkshelf.client_key = ''
  #config.berkshelf.nodename = ''


  config.vm.provision :chef_solo do |chef|
    chef.log_level = 'debug'
    chef.json = {
      :iis_arr => {
      },
      :minitest=> {
        :ci_reports => '/tmp/ci_reports/'
      }
    }

    chef.run_list = [
        #"recipe[iis_arr::default]",
        "recipe[iis_arr::test_recipe]",
        "recipe[minitest-handler::default]"
    ]
  end
end
