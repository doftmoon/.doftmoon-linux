# -*- mode: ruby -*-
# vi: set ft=ruby :
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 doftmoon

Vagrant.configure("2") do |config|

  config.vm.synced_folder ".", "/home/vagrant/.doftmoon-linux", disabled: true

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "2024"
    vb.cpus = 2
  end

  config.vm.define "arch" do |arch|
    arch.vm.box = "generic/arch"
    arch.vm.box_version = "4.3.12"

    arch.vm.hostname = "arch-test"

    arch.vm.provision "shell", inline: <<-SHELL
      sudo pacman -Syu --noconfirm
      sudo pacman -S --noconfirm git
    SHELL
  end

  config.vm.define "fedora" do |fedora|
    fedora.vm.box = "generic/fedora39"

    fedora.vm.hostname = "fedora-test"

    fedora.vm.provision "shell", inline: <<-SHELL
      sudo dnf update -y
    SHELL
  end

  config.vm.define "ubuntu" do |ub|
    ub.vm.box = "ubuntu/jammy64"

    ub.vm.hostname = "ubuntu-test"

    ub.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update -y
      sudo apt-get install git -y
      git clone https://github.com/doftmoon/.doftmoon-linux.git /home/vagrant/.doftmoon-linux
    SHELL
  end
end
