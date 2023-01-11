#!/bin/bash

. ./deploy_lib/Log.sh
. ./deploy_lib/Installer.sh
. ./deploy_lib/const.sh

prepareLocalEnv() {
  infoColor="1;35m"
  echo "\n\n\n\n\n\n"
  inf "local environment" "Application boot started. Preparing environment..."

  createWorkDir 2>/dev/null
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "local environment" "Can not create work directory. Directory does not exist. Program will exit now as this is vital for its functionality."
    exit
  fi

  installPython 2>&1 | tee $WORKDIR/log/local.log
  installLinodeCli 2>&1 | tee $WORKDIR/log/local.log
# special sign removal (some shit colours)
  sed $'s/[^[:print:]\t]//g' $WORKDIR/log/local.log

  cd work
  echo "\n\n"
  inf "local application" "App started by $(whoami)"
  sh Local.sh
}

createWorkDir() {
  if [ -d "$WORKDIR" ]; then
    inf "local environment" "Work directory already exists. If terraform files were changed, it requires manual deletion."
  else
    mkdir $WORKDIR
    cd $WORKDIR
    mkdir log
    mkdir db
    cd ..
    inf "local environment" "Success - Create work directory"
  fi
  populateWorkFolder
}

populateWorkFolder() {
  if [ -n "$(ls -A $WORKDIR/tf 2>/dev/null)" ]; then
    inf "local environment" "Terraform folder already exists, overwrite is not performed automatically."
  else
    cp -r ./tf $WORKDIR
    isError=$?
    if [[ $isError -eq 1 ]]; then
      err "local environment" "Can not copy terraform folder. Check if working directory exists or root folder is OK"
      exit
    fi
    inf "local environment" "Success - Copy terraform files to work directory"
  fi

  cp -r ./deploy_lib $WORKDIR
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "local environment" "Can not copy deploy_lib folder. Check if working directory exists or root folder is OK"
    exit
  fi
  inf "local environment" "Success - Copy deploy_lib files to work directory"

  cp -r ./bin $WORKDIR
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "local environment" "Can not copy bin folder. Check if working directory exists or root folder is OK"
    exit
  fi
  inf "local environment" "Success - Copy bin files to work directory"

  cp ./deploy_lib/Local.sh $WORKDIR
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "local environment" "Can not copy run script. Check if working directory exists or root folder is OK"
    exit
  fi
  inf "local environment" "Success - Copy run script files to work directory"
}

prepareLocalEnv
