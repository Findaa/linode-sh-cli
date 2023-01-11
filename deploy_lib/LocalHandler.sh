#!/bin/bash

. ./deploy_lib/CloudHandler.sh
. ./deploy_lib/DatabaseManager.sh
. ./deploy_lib/Installer.sh

kubeHostDeploy() {
  cat /dev/null >log/tf.log
  sed $'s/[^[:print:]\t]//g' log/tf.log
  databaseUpdate

  optionalHost=$(getNodeIpByName 'terraformHost')
  if [[ -n $optionalHost ]]; then
    err "local deploy" "Could not deploy kubernetes host. Host exists $optionalHost"
  else
    kubeHostCreate && handshakeWithHost
    handshakeWithHost && kubeHostConfigure

  fi
}

kubeHostConfigure() {
  hostIp=$(getNodeIpByName 'terraformHost')
  uploadWorkFiles
  installLibrariesRemoteHost
  installTerraformRemote
  installKubectlRemote
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
  waiter "before handshake try..."
  inf "integration\t" "Adding $hostIp to the list of known hosts. This may take a moment as connection needs to be confirmed first."
  inf "integration\t" "Trying to execute ssh -t -t -o 'StrictHostKeyChecking accept-new' root@$hostIp 'echo hello'"
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
    err "local terraform" "Linode engine could not be deleted. Probably the work folder was deleted manually. Remove cloud host from linode UI or with cli"
  else
    inf "local terraform" "Remote kubernetes host removed."
  fi

  cd ../..
  databaseUpdate
}

uploadWorkFiles() {
  find . -name ".DS_Store" -delete
  scpAddress="root@$hostIp:/tmp/work"

  inf "cloud\t\t" "Creating $scpAddress/bin"
  sshConnector 'terraformHost' 'cd ../tmp/ && mkdir work && cd work && mkdir bin && mkdir tf'

  inf "cloud\t\t" "Performing upload to $scpAddress"
  scp -rB bin $scpAddress
  scp -rB deploy_lib $scpAddress
  scp -rB tf/cluster $scpAddress/tf
  scp -rB tf/terraform.auto.tfvars $scpAddress/tf
  scp -rB tf $scpAddress
  scp -rB Local.sh $scpAddress
  #todo: if err
  inf "cloud\t\t" "All files uploaded"
}

waiter() {
  inf "integration\t" "Waiting 10 seconds $1"
  sleep 1
  inf "integration\t" "Waiting 9 seconds $1"
  sleep 1
  inf "integration\t" "Waiting 8 seconds $1"
  sleep 1
  inf "integration\t" "Waiting 7 seconds $1"
  sleep 1
  inf "integration\t" "Waiting 6 second $1"
  sleep 1
  inf "integration\t" "Waiting 5 seconds $1"
  sleep 1
  inf "integration\t" "Waiting 4 seconds $1"
  sleep 1
  inf "integration\t" "Waiting 3 seconds $1"
  sleep 1
  inf "integration\t" "Waiting 2 seconds $1"
  sleep 1
  inf "integration\t" "Waiting 1 second $1"
  sleep 1
}
