#!/bin/bash

. ./deploy_lib/LocalActions.sh
. ./deploy_lib/DatabaseManager.sh
. ./deploy_lib/Log.sh

export LINODE_CLI_TOKEN="949505f61e40135f06bf04fe99c699d15b008f8ca2a6e430d437fd3b752735ab"
WORKDIR="./work"

main() {
  PS3='Please enter your choice: '
  options=("Create kube host" "Create cluster" "Delete host" "Delete cluster" "List nodes" "Quit")
  select opt in "${options[@]}"; do
    case $opt in
    "Create kube host")
      prepareLocalEnv
      kubeHostCreate
      updateWorkDir
      printOptions
      ;;
    "Create cluster")
      getKubeHostIp
      updateWorkDir
      printOptions
      ;;
    "Delete host")
      kubeHostDestroy
      updateWorkDir
      printOptions
      ;;
    "Delete cluster")
      echo "you chose choice $REPLY which is $opt"
      ;;
    "List nodes")
      printNodes
      printOptions
      ;;
    "Quit")
      break
      ;;
    *) echo "invalid option $REPLY"
      ;;
    esac
  done
}

printOptions() {
  echo "\n1.) Create kube host 2.) Create cluster 3.) Delete host 4.) Delete cluster 5.) List nodes 6.) Quit"
}

createWorkDir() {
  mkdir $WORKDIR
  cd $WORKDIR
  mkdir log
  mkdir db
  cd ..
}

prepareLocalEnv() {
  createWorkDir 2>/dev/null
  isError=$?
  if [[ $isError -eq 1 ]]; then
    if [ -d "$WORKDIR" ]; then
      inf "engine start" "Success - Work directory already exists. Deleting its contents"
      rm -rf $WORKDIR
    else
      err "engine start" "Can not create work directory. Directory does not exist"
      exit
    fi
  else
    inf "engine start" "Success - Create work directory"
  fi

  installPython 2>&1 | tee $WORKDIR/log/local.log
  installLinodeCli 2>&1 | tee $WORKDIR/log/local.log
}

installPython() {
  python3 --version
  isError=$?
  if [[ $isError -eq 0 ]]; then
    inf "python3" "Python3 already installed"
  else
    sudo apt update
    sudo apt install python3
    inf "python3" "Python3 installed successfully"
  fi

  pip3 --version
  isError=$?
  if [[ $isError -eq 0 ]]; then
    inf "python3" "Pip3 already installed"
  else
    sudo apt install python3-pip
    inf "python3" "Pip3 installed successfully"
  fi
}

installLinodeCli() {
  linode-cli --version 2>/dev/null
  isError=$?
  if [[ $isError -eq 0 ]]; then
    inf "linode-cli" "Linode cli already installed"
    exit
  else
    pip3 install linode-cli --upgrade
    pip3 install boto
  fi

  linode-cli --version 2>/dev/null
  isError=$?
  if [[ $isError -eq 0 ]]; then
    inf "linode-cli" "Linode cli installed successfully"
  else
    err "linode-cli" "Could not install linode cli"
  fi
}

updateWorkDir() {
  if [ -d "$WORKDIR" ]; then
    saveNodesAsCsv
  fi
}

main
