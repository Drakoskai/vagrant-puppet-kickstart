#!/bin/bash

set -e

ubuntu() {
  uname -a | grep -q Ubuntu && return 0 || return 1
}

say() {
  echo "** $@"
}

gem_install() {
  GEM_FILE="$@"
  if ! gem list | grep -q $GEM_FILE; then
    say "Installing GEM $GEM_FILE"
    gem install --no-rdoc --no-ri -V $GEM_FILE
  fi
}

install_dependencies() {
  if ubuntu; then   
    DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
    CODENAME=$(lsb_release -cs)
    apt-get update
    say "Installing Python..."
    sudo apt-get install --yes --force-yes python-setuptools python-dev build-essential python-pip
    sudo pip install PyYAML
    say "python version: `python --version`"
    
    say "Installing Puppet..."
    binary_name="puppetlabs-release-${CODENAME}.deb"
    sudo wget -q https://apt.puppetlabs.com/$binary_name
    sudo dpkg -i $binary_name
    
    sudo apt-get update
   
    sudo apt-get install --yes --force-yes puppet rubygems-integration  
    sudo apt-get install --yes --no-install-recommends --force-yes --only-upgrade puppet 2>/dev/null
    
    say "puppet version: `puppet --version`"
    
    gem_install librarian-puppet
    
    sudo cp -a /tmp/puppet /etc
    cd /etc/puppet && sudo librarian-puppet install
    
  else
    say "operating system not supported."
    exit 1
  fi  
}

install_dependencies
