#!/bin/bash

kubeHostCreate() {
  cat /dev/null > log/tf.log
  kubeHostDeploy 2>&1 | tee log/tf.log
  sed $'s/[^[:print:]\t]//g' log/tf.log
}

kubeHostDeploy() {
  cd tf/engine
  terraform init
  terraform plan
  terraform apply -auto-approve
  cd ../..
}

#Needs rework for label based removal from IP.
kubeHostDestroy() {
  inf "test" $(pwd)
  cd tf/engine
  terraform destroy -auto-approve --target linode_instance.kubeHost
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "engine destroy" "Can not delete linode engine."
  else
    inf "engine destroy" "Kube host should not exist now. Check if connected worker nodes are removed."
  fi
  inf "test2" $(pwd)
  cd ../..
  inf "test3" $(pwd)

}
