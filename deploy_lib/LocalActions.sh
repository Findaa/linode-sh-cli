#!/bin/bash

. ./deploy_lib/CloudActions.sh
. ./deploy_lib/DatabaseManager.sh

kubeHostCreate() {
  cat /dev/null > log/tf.log
  sed $'s/[^[:print:]\t]//g' log/tf.log
  databaseUpdate
  optionalHost=$(getNodeIpByName 'terraformHost')

  if [[ -n $optionalHost ]]; then
    err "local deploy" "Could not deploy kubernetes host. Host exists $optionalHost"
  else
    kubeHostDeploy 2>&1 | tee log/tf.log
    databaseUpdate
    uploadWorkFiles
    installTerraformRemoteHost
  fi
}

kubeHostDeploy() {
  inf "local terraform" "Starting to deploy kube host"
  cd tf/engine
  terraform init
  terraform plan -var-file="../terraform.auto.tfvars"
  terraform apply -var-file="../terraform.auto.tfvars" -auto-approve
  cd ../..
}

#todo: label based removal from IP. Remove worker nodes first too.
kubeHostDestroy() {
  hostIp=$(getNodeIpByName 'terraformHost')
  ssh-keygen -f ~/.ssh/known_hosts -R $hostIp 2>&1 | tee log/local.log
  inf "local terraform" "Destroying kube host. Removing $hostIp from known hosts "

  cd tf/engine
  terraform destroy -var-file="../terraform.auto.tfvars" -auto-approve --target linode_instance.kubeHost

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "local" "Linode engine could not be deleted. Probably the work folder was deleted manually. Remove cloud host from linode UI or with cli"
  else
    inf "local" "Remote kubernetes host removed."
  fi

  cd ../..
}
