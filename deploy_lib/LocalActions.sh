#!/bin/bash

kubeHostCreate() {
  populateWorkFolder 2>/dev/null
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "engine start" "Can not copy terraform folder. Check if working directory exists or root folder is OK"
    echo $(pwd)
    exit
  fi
  inf "engine start" "Success - Copy terraform files to work directory"

  cat dev/null >$WORKDIR/log/tf.log
  deployKubeHost 2>&1 | tee $WORKDIR/log/tf.log

}

populateWorkFolder() {
  cp -r ./tf $WORKDIR
  cp -r ./deploy_lib $WORKDIR
}

deployKubeHost() {
  cd $WORKDIR/tf/engine
  terraform init
  terraform plan
  terraform apply -auto-approve
  cd ../..
}

kubeHostDestroy() {
  cd $WORKDIR/tf/engine
  terraform destroy -auto-approve
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "engine destroy" "Can not delete linode engine."
  else
    inf "engine destroy" "Kube host doest not exist now. Check if connected worker nodes are removed."
  fi
  cd .. && remove -rf ./engine
  cd ..
  echo "current dir test: " $(pwd)
}
