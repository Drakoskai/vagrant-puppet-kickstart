# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

VAGRANTFILE_API_VERSION = "2"
VAGRANT_CONFIG = "./config.yaml"
VAGRANT_DEFAULT_CONFIG = "./default.yaml"

def vagrant_boxes &block
  @config = ( File.exist?( VAGRANT_CONFIG ) ) ? load_box_config : load_default_box_config
  if ( @config.empty? )
	 @config = ( load_default_box_config )
  end
  @config['boxes'].each { |x| yield x }
end

def load_default_box_config
  YAML.load(File.read( VAGRANT_DEFAULT_CONFIG )) || []
end

def load_box_config
  YAML.load(File.read( VAGRANT_CONFIG )) || []
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.synced_folder 'puppet/', '/tmp/puppet', disabled: false
  vagrant_boxes do |settings|
      # Prevent "default: stdin: is not a tty" error
      config.vm.provision "fix-no-tty", type: "shell" do |s|
      s.privileged = false
      s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
    end
    config.vm.define settings['hostname'] do |s|
      s.vm.box = settings['box_name']
      s.vm.box_url = settings['box_url']
      s.vm.host_name = settings['hostname']
      if settings['bootstrap']
        case settings['bootstrap']['type']
        when 'script'
          config.vm.provision :shell, :path => settings['bootstrap']['script']
        end
      end
      ##### Provider Virtual Box
      s.vm.provider :virtualbox do |v, override|  
        config.vm.provision :shell, :inline => 'cp -a /tmp/puppet /etc'
        v.gui   = settings['gui'] || false
        v.name  = settings['hostname']
        (settings['spec'] || {}).each_pair do |key,value|
          v.customize [ "modifyvm", :id, "--#{key}", value ]
        end
        ( settings['networks'] || [] ).each do |n|
          config.vm.network n['name'], type: :dhcp if n['type'] == 'dhcp'
          config.vm.network n['name'], ip: n['ip'] if n['ip']
        end
      end
      #### End Provider Virtual Box
    end
  end
end
