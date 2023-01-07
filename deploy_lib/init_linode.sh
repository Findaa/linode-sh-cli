#!/bin/bash

. ./deploy_lib/log.sh

engineCreate() {
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

  copyTerraformFiles 2>/dev/null
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "engine start" "Can not copy terraform folder. Check if working directory exists or root folder is OK"
    echo $(pwd)
    exit
  fi
  inf "engine start" "Success - Copy terraform files to work directory"

  createKubeHost 2>&1 | tee $WORKDIR/log/tf.log
}

createWorkDir() {
  mkdir $WORKDIR/log
}

copyTerraformFiles() {
  cp -r ./tf $WORKDIR
}

createKubeHost() {
  cd $WORKDIR/engine
  terraform init
  terraform plan
  terraform apply -auto-approve
  cd ../..
}

engineDestroy() {
  cd $WORKDIR/engine
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
