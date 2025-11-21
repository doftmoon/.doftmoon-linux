#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 doftmoon
#
# Script to install all dep and automate init process
set -euo pipefail

USER='doftmoon'
CURRENT_USER=$(whoami)

WORK_HOST='ThinkPad'

PROFILE=''

GIT_REPO="https://github.com/$USER/.$USER-linux.git"

ensure_not_root() {
   if [[ "$EUID" -eq 0 ]]; then
      error "Don't run as root!"
   fi
}

info() {
   if command -v gum &>/dev/null; then
      gum style --foreground 10 "$1"
   else
      echo -e "\e[32mINFO:\e[0m $1"
   fi
}

warn() {
   if command -v gum &>/dev/null; then
      gum style --foreground 11 "$1"
   else
      echo -e "\e[33mWARNING:\e[0m $1"
   fi
}

error() {
   if command -v gum &>/dev/null; then
      gum style --foreground 9 "$1" >&2
   else
      echo -e "\e[31mERROR:\e[0m $1" >&2
   fi
   exit 1
}

confirm() {
   if command -v gum &>/dev/null; then
      gum confirm "$1"
   else
      echo -n "$1 (y/n): "; read -r r; [[ "$r" =~ [Yy]$ ]]
   fi
}

choose() {
   local prompt="$1"
   shift
   if command -v gum &>/dev/null; then
      gum choose --cursor.foreground 12 --header="$prompt" --header.foreground 12 "$@"
   elif command -v fzf &>/dev/null; then
      printf "%s\n" "$@" |
         fzf --prompt="$prompt" \
            --height=20% \
            --border --cycle
   else
      select opt in "$@"; do [[ -n "$opt" ]] && { echo "$opt"; break; }; done
   fi
}

install_deps() {
   local packages_pacman='base-devel file curl git python-pipx gum'
   local packages_zypper='gum'
   local packages_dnf='gum'
   local packages_apt='build-essential file curl git pipx'
   local mgrs=(pacman dnf zypper apt)
   local mgr=$(for m in ${mgrs[@]}; do command -v $m &>/dev/null && { echo ${m%%-*}; break; }; done)
   info "Package manager: $mgr"

   case $mgr in
      pacman) sudo pacman -S $packages_pacman --needed --noconfirm ;;
      dnf) sudo dnf install $packages_dnf -y ;;
      zypper) sudo zypper install gum -y ;;
      # refrence https://github.com/basecamp/omakub/issues/222
      apt)
         sudo apt update -y
         sudo apt upgrade -y
         sudo apt install $packages_apt -y
         if ! command -v gum &>/dev/null; then
            warn "In order to install gum and lots of other modern terminal tools"
            warn "The Charm repository needs to be added for apt in order to get package"
            warn "this repo and Charm company is a well-known source of high-quality tools"
            if confirm "Do you want to add Charm repository for apt?"; then
               info "Adding Charm repository for apt..."
               sudo mkdir -p /etc/apt/keyrings
               curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
               echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
               sudo apt install gum -y
            else
               warn "Canceled operation"
            fi
         fi
         sudo apt autoremove
         ;;
      *) error "Cannot install dependecies automatically" ;;
   esac
   info 'Dependencies installed'
}

install_ansible() {
   info 'Checking for ansible installation...'
   if ! command -v ansible &>/dev/null; then
      pipx install ansible
      pipx ensurepath
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
      git checkout master
   fi
}

check_user() {
   if [[ "$USER" != "$CURRENT_USER" ]]; then
      warn "The user that is running this bootstrap is different to creator $USER"
   else
      info "New installation, Master? >_<"
      info "or...you forgot that everything already have been installed..."
   fi
}

run_ansible() {
   info 'Starting ansible play...'
   (cd ansible && ~/.local/pipx/venvs/ansible/bin/ansible-playbook -K playbook.yaml)
}

main() {
   ensure_not_root
   install_deps
   install_ansible
   ensure_latest_repo
   check_user
   #choose_installation
   #check_device
   run_ansible
   info 'Bootstrap complete!'
}

main
