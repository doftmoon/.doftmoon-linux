#!/usr/bin/env bash
# Script to install all dep and automate init process
set -euo pipefail
source ./libs/doftmoon-shell-utils
# info()
# error()
# ensure_not_root()
# detect_package_manager()

USER='doftmoon'
GIT_REPO="https://github.com/$USER/.$USER-linux.git"
PKG_MANAGER=$(detect_package_manager)

install_dependencies() {
   local packages_apt='build-essential file curl git pipx'
   local packages_pacman='base-devel file curl git python-pipx'
   local packages_dnf=''
   local packages_apk=''

   info 'Installing dependencies via package manager...'
   case "$PKG_MANAGER" in
      'apt')
         sudo apt update
         sudo apt upgrade
         sudo apt install $packages_apt
         sudo apt autoremove
         ;;
      'pacman')
         sudo pacman -Syu --noconfirm
         sudo pacman -S --noconfirm $packages_pacman
         ;;
      'dnf')
         error 'Fedora is not supported now! Aborting.'
         ;;
      'apk')
         error 'Alpine is not supported now! Aborting.'
         ;;
      *)
         error 'Unknown package manager. Aborting.'
         ;;
   esac
   info 'Successfully installed!'
}

install_ansible() {
   info 'Checking for ansible installation...'
   if ! command -v ansible &> /dev/null; then
      pipx install ansible
      sudo pipx ensurepath --global
      info 'Ansible successfully installed!'
   else
      info 'Ansible is already installed!'
   fi
}

ensure_latest_repo() {
   info 'Checking if git repo is up to date...'
   if [[ $(git remote show) = 'origin' ]]; then
      git pull origin
   else
      git remote add origin $GIT_REPO
      git pull origin master
   fi
}

run_ansible() {
   info 'Starting ansible play...'
   (cd ansible && ~/.local/bin/ansible-playbook -K --check playbook.yaml -e "github_user=$USER")
}

main() {
   ensure_not_root # ensures the script is run as a normal user with sudo privileges
   install_dependencies
   install_ansible
   #ensure_latest_repo
   run_ansible
   info 'Bootstrap complete!'
}

main
