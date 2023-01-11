#!/bin/bash

. ./deploy_lib/CloudActions.sh
. ./deploy_lib/DatabaseManager.sh

kubeHostDeploy() {
  cat /dev/null >log/tf.log
  sed $'s/[^[:print:]\t]//g' log/tf.log
  databaseUpdate

  optionalHost=$(getNodeIpByName 'terraformHost')
  if [[ -n $optionalHost ]]; then
    err "local deploy" "Could not deploy kubernetes host. Host exists $optionalHost"
  else
    kubeHostCreate 2>&1 | tee log/tf.log
    handshakeWithHost
    uploadWorkFiles
    installTerraformRemoteHost
  fi
}

kubeHostCreate() {
  inf "local terraform" "Starting to deploy kube host"
  cd tf/engine
  terraform init
  inf "local terraform" "Terraform initialized. Planning..."
  terraform plan -var-file="../terraform.auto.tfvars" 2>1 1>/dev/null
  inf "local terraform" "Terraform planned. Deploying..."
  terraform apply -var-file="../terraform.auto.tfvars" -auto-approve 2>1 1>/dev/null
  cd ../..
  databaseUpdate
}

handshakeWithHost() {
  hostIp=$(getNodeIpByName 'terraformHost')
  waiter
  inf "local-cloud integration" "Adding $hostIp to the list of known hosts. This may take a moment as connection needs to be confirmed first."
  inf "local cloud integration" "Trying to execute ssh -t -t -o 'StrictHostKeyChecking accept-new' root@$hostIp 'echo hello'"
  ssh -t -t -o 'StrictHostKeyChecking accept-new' root@$hostIp 'echo hello $(pwd)'
}

#todo: label based removal by IP. Remove worker nodes first too.
kubeHostDestroy() {
  hostIp=$(getNodeIpByName 'terraformHost')
  inf "local terraform" "Destroying kube host. Removing $hostIp from known hosts "
  ssh-keygen -f ~/.ssh/known_hosts -R $hostIp 2>&1 | tee log/local.log
  inf "local terraform" "Destroying kube host. Removing related kube worker nodes"
  kubeClusterDestroy
  inf "local terraform" "Destroying kube host"
  cd tf/engine
  terraform destroy -var-file="../terraform.auto.tfvars" -auto-approve --target linode_instance.kubeHost 2>1 1>/dev/null

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "local" "Linode engine could not be deleted. Probably the work folder was deleted manually. Remove cloud host from linode UI or with cli"
  else
    inf "local" "Remote kubernetes host removed."
  fi

  cd ../..
  databaseUpdate
}

waiter() {
  inf "local-cloud integration" "Waiting 10 seconds before handshake try..."
  sleep 1
  inf "local-cloud integration" "Waiting 9 seconds before handshake try..."
  sleep 1
  inf "local-cloud integration" "Waiting 8 seconds before handshake try..."
  sleep 1
  inf "local-cloud integration" "Waiting 7 seconds before handshake try..."
  sleep 1
  inf "local-cloud integration" "Waiting 6 second before handshake try..."
  sleep 1
  inf "local-cloud integration" "Waiting 5 seconds before handshake try..."
  sleep 1
  inf "local-cloud integration" "Waiting 4 seconds before handshake try..."
  sleep 1
  inf "local-cloud integration" "Waiting 3 seconds before handshake try..."
  sleep 1
  inf "local-cloud integration" "Waiting 2 seconds before handshake try..."
  sleep 1
  inf "local-cloud integration" "Waiting 1 second before handshake try..."
  sleep 1
}