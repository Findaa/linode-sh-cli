#!/bin/bash

. ./deploy_lib/CloudActions.sh

kubeHostCreate() {
  cat /dev/null > log/tf.log
  kubeHostDeploy 2>&1 | tee log/tf.log
  sed $'s/[^[:print:]\t]//g' log/tf.log
  databaseUpdate
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

#todo: label based removal from IP. Remove from known hosts. Remove worker nodes first too.
kubeHostDestroy() {
  cd tf/engine
  terraform destroy -auto-approve --target linode_instance.kubeHost

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "local" "Linode engine could not be deleted."
  else
    inf "local" "Remote kubernetes host removed."
  fi

  cd ../..
}
