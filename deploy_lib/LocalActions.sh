#!/bin/bash

. ./deploy_lib/CloudActions.sh

kubeHostCreate() {
  cat /dev/null > log/tf.log
  kubeHostDeploy 2>&1 | tee log/tf.log
  sed $'s/[^[:print:]\t]//g' log/tf.log
  databaseUpdate
  sshConnector 'terraformHost' 'ls 1>/dev/null'
  uploadWorkFiles
  installTerraformRemoteHost
}

kubeHostDeploy() {
  echo $(pwd)
  cd tf/engine
  terraform init
  terraform plan
  terraform apply -auto-approve
  cd ../..
}

#todo: label based removal from IP. Remove from known hosts
kubeHostDestroy() {
  cd tf/engine
  terraform destroy -auto-approve --target linode_instance.kubeHost

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "engine destroy" "Can not delete linode engine."
  else
    inf "engine destroy" "Kube host should not exist now. Check if connected worker nodes are removed."
  fi

  cd ../..
}
