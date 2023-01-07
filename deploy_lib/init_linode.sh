#!/bin/bash

. ./deploy_lib/log.sh

prepareEnv() {
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
}

engineCreate() {
  copyTerraformFiles 2>/dev/null
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "engine start" "Can not copy terraform folder. Check if working directory exists or root folder is OK"
    echo $(pwd)
    exit
  fi
  inf "engine start" "Success - Copy terraform files to work directory"

#  installPython 2>&1
  cat dev/null > $WORKDIR/log/tf.log
  createKubeHost 2>&1 | tee $WORKDIR/log/tf.log
#  installLinodeCli 2>&1 | tee $WORKDIR/log/tf.log
}

createWorkDir() {
  mkdir $WORKDIR
  cd $WORKDIR
  mkdir log
  cd ..
}

copyTerraformFiles() {
  cp -r ./tf $WORKDIR
}

createKubeHost() {
  cd $WORKDIR/tf/engine
  terraform init
  terraform plan
  terraform apply -auto-approve
  cd ../..
}

engineDestroy() {
  cd $WORKDIR/tf/engine
  terraform destroy -auto-approve
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "engine destroy" "Can not delete linode engine."
  else
    inf "engine destroy" "Kube host removed successfully. Check worker nodes."
  fi
  cd .. && remove -rf ./engine
  cd ..
  echo "current dir test: " $(pwd)
}

testFunction() {
  touch test.txt
}

installPython() {
  python3 --version
  isError=$?
  if [[ $isError -eq 0 ]]; then
    inf "python3" "Python3 already installed"
  else
    sudo apt update
    sudo apt install python3
    inf "python3" "Python3 installed"
  fi

  pip3 --version
  isError=$?
  if [[ $isError -eq 0 ]]; then
    inf "python3" "Pip3 already installed"
  else
    sudo apt install python3-pip
    inf "python3" "Pip3 installed"
  fi
}

installLinodeCli() {
  pip3 install linode-cli --upgrade
  pip3 install boto
  linode-cli --help
  isError=$?
  if [[ $isError -eq 0 ]]; then
    inf "linode-cli" "Linode cli installed sucessfully"
    export LINODE_CLI_TOKEN="949505f61e40135f06bf04fe99c699d15b008f8ca2a6e430d437fd3b752735ab"
  else
    err "linode-cli" "Could not install linode cli"
  fi
}
