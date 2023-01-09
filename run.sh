#!/bin/bash

. ./deploy_lib/Log.sh

WORKDIR="./work"
export LINODE_CLI_TOKEN="949505f61e40135f06bf04fe99c699d15b008f8ca2a6e430d437fd3b752735ab"

prepareLocalEnv() {
  createWorkDir 2>/dev/null
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "local start" "Can not create work directory. Directory does not exist. Program will exit now as this is vital for its functionality."
    exit
  fi

  installPython 2>&1 | tee $WORKDIR/log/local.log
  installLinodeCli 2>&1 | tee $WORKDIR/log/local.log
# special sign removal (some shit colours)
  sed $'s/[^[:print:]\t]//g' $WORKDIR/log/local.log

  cd work
  echo "\n\n"
  sh worker.sh
}

createWorkDir() {
  if [ -d "$WORKDIR" ]; then
    inf "local start" "Work directory already exists. If terraform files were changed, it requires manual deletion."
  else
    mkdir $WORKDIR
    cd $WORKDIR
    mkdir log
    mkdir db
    cd ..
    inf "local start" "Success - Create work directory"
  fi
  populateWorkFolder
}

populateWorkFolder() {
  if [ -n "$(ls -A $WORKDIR/tf 2>/dev/null)" ]; then
    inf "engine start" "Terraform folder already exists, overwrite is not performed automatically."
  else
    cp -r ./tf $WORKDIR
    isError=$?
    if [[ $isError -eq 1 ]]; then
      err "engine start" "Can not copy terraform folder. Check if working directory exists or root folder is OK"
      exit
    fi
    inf "engine start" "Success - Copy terraform files to work directory"
  fi

  cp -r ./deploy_lib $WORKDIR
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "engine start" "Can not copy deploy_lib folder. Check if working directory exists or root folder is OK"
    exit
  fi
  inf "engine start" "Success - Copy deploy_lib files to work directory"

  cp ./deploy_lib/worker.sh $WORKDIR
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "engine start" "Can not copy run script. Check if working directory exists or root folder is OK"
    exit
  fi
  inf "engine start" "Success - Copy run script files to work directory"
}

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

prepareLocalEnv
