#!/usr/bin/env bash
# Script to install all dep and automate init process
# NOTICE: run only 1 "one" time!!! Rn hove not enough time to test everything :3
set -e

USER='doftmoon'
GIT_REPO='https://github.com/doftmoon/.doftmoon-linux.git'
PKG_MANAGER='unknown'

RED='\033[0;31m'
SAKURA='\033[38;2;219;184;213m'
NC='\033[0m'

info() {
   echo -e "${SAKURA}INFO: $1${NC}"
}

error() {
   echo -e "${RED}ERROR:${NC} $1" >&2
   exit 1
}

ensure_not_root() {
   if [[ $EUID -eq 0 ]]; then
      error 'This script must be run as a normal user with sudo priveleges, not as root!'
   fi
}

get_sudo_session() {
   sudo -v
   while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

detect_package_manager() {
   info 'Detecting package manager...'
   if command -v apt-get &> /dev/null; then
      PKG_MANAGER='apt'
   elif command -v pacman &> /dev/null; then
      PKG_MANAGER='pacman'
   elif command -v dnf &> /dev/null; then
      PKG_MANAGER='dnf'
   elif command -v apk &> /dev/null; then
      PKG_MANAGER='apk'
   else
      error 'Could not detect a known package manager. Aborting.'
   fi

   info "Detected package manager: $PKG_MANAGER"
   sleep 1
}

install_dependencies() {
   local packages_apt='build-essential file curl git pipx'
   local packages_pacman='base-devel file curl git python-pipx'

   info 'Installing dependencies via package manager.'
   if [ "$PKG_MANAGER" = 'apt' ]; then
      sudo apt update
      sudo apt upgrade
      sudo apt install $packages_apt
      sudo apt autoremove
   elif [ "$PKG_MANAGER" = 'pacman' ]; then
      sudo pacman -Syu --noconfirm
      sudo pacman -S --noconfirm $packages_pacman
   elif [ "$PKG_MANAGER" = 'dnf' ]; then
      error 'Fedora is not supported now!'
   elif [ "$PKG_MANAGER" = 'apk' ]; then
      error 'Alpine is not supported now!'
   fi
}

install_ansible() {
   info 'Checking for ansible installation...'
   if ! command -v ansible &> /dev/null; then
      pipx install ansible
      sudo pipx ensurepath --global
   else
      info 'Ansible is already installed.'
   fi
}

ensure_latest_repo() {
   info 'Checking if git repo is up to date...'
   if [[ $(git remote show) = 'origin' ]]; then
      git pull origin master
   else
      git remote add origin $GIT_REPO
      git pull origin master
   fi
}

run_ansible() {
   info 'Starting ansible play...'
   ~/.local/bin/ansible-playbook --ask-become-pass playbook.yaml -e "github_user=$USER"
}

main() {
   ensure_not_root # ensures the script is run as a normal user with sudo privileges
   get_sudo_session # get the sudo privileges for the script
   detect_package_manager
   install_dependencies
   install_ansible
   ensure_latest_repo
   run_ansible
   info 'Bootstrap complete!'
}

main
