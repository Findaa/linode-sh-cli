#!/bin/bash

kubeHostCreate() {
  cat dev/null > log/tf.log
  deployKubeHost 2>&1 | tee log/tf.log
  sed $'s/[^[:print:]\t]//g' log/tf.log
}

deployKubeHost() {
  cd tf/engine
  terraform init
  terraform plan
  terraform apply -auto-approve
  cd ../..
}

kubeHostDestroy() {
  cd tf/engine
  terraform destroy -auto-approve

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "engine destroy" "Can not delete linode engine."
  else
    inf "engine destroy" "Kube host doest not exist now. Check if connected worker nodes are removed."
  fi
}
