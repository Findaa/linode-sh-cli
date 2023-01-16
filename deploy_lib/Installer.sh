#!/bin/bash

. ./deploy_lib/CloudHandler.sh

installPython() {
  python3 --version
  isError=$?
  if [[ $isError -eq 0 ]]; then
    inf "local python3" "Python3 already installed"
  else
    sudo apt update
    sudo apt install python3
    inf "local python3" "Python3 installed successfully"
  fi

  pip3 --version
  isError=$?
  if [[ $isError -eq 0 ]]; then
    inf "local python3" "Pip3 already installed"
  else
    sudo apt install python3-pip
    inf "local python3" "Pip3 installed successfully"
  fi
}

installLinodeCli() {
  linode-cli --version 2>/dev/null
  isError=$?
  if [[ $isError -eq 0 ]]; then
    inf "local linode-cli" "Linode cli already installed"
    exit
  else
    pip3 install linode-cli --upgrade
    pip3 install boto
  fi

  linode-cli --version 2>/dev/null
  isError=$?
  if [[ $isError -eq 0 ]]; then
    inf "local linode-cli" "Linode cli installed successfully"
  else
    err "local linode-cli" "Could not install linode cli"
  fi
}

installTerraformRemote() {
  inf "engine\t\t" "Installing terraform for kube host"
  sshConnector 'terraformHost' 'cd ../tmp/work/bin && mv terraform /usr/local/bin/ && terraform -v'
  inf "engine\t\t" "Terraform installed."
}

installKubectlRemote() {
  inf "engine\t\t" " Installing kubectl..."
  sshConnector 'terraformHost' 'cd ../tmp/work/bin && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && kubectl version --client'
  inf "engine\t\t" "Kubectl installed"
}
