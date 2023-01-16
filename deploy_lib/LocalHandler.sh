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
    kubeHostCreate && handshakeWithHost && kubeHostConfigure
    inf "local deploy" "Kube host initialized successfully"
  fi
}

kubeHostConfigure() {
  hostIp=$(getNodeIpByName 'terraformHost')
  uploadWorkFiles
  installTerraformRemote
  installKubectlRemote
  sshConnector 'terraformHost' 'export infoColor="36;49m"'

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
  try=1

  if [[ $try -eq 3 ]]; then
    err "integration" "Connection to root@$hostIp could not be established after 3 tries. Reverting changes"
    kubeHostDestroy
  fi

  inf "integration\t" "Offering handshake from $(whoami) to root@$hostIp (Attempt $try/3)"
  ssh -t -t -o 'StrictHostKeyChecking accept-new' root@$hostIp 'echo hello $(pwd)'

  isError=$?
  if [[ $isError -eq 0 ]]; then
    inf "integration" "Added $hostIp to the list of known hosts. Connection may be established now."
  else
    try=$(echo "$try+1" | bc)
    err "integration" "Connection to root@$hostIp could not be established. Trying again. (Attempt $try/3)"
    waiter "before another handshake try..."
    handshakeWithHost
  fi
}

#todo: Label based removal by IP.
kubeHostDestroy() {
  hostIp=$(getNodeIpByName 'terraformHost')

  inf "local terraform" "Destroying kube host $hostIp. Removing related kube worker nodes"
  kubeClusterDestroy

  inf "local terraform" "Destroying kube host"
  cd tf/engine
  terraform destroy -var-file="../terraform.auto.tfvars" -auto-approve --target linode_instance.kubeHost 2>&1 1>/dev/null

  inf "local terraform" "Kube host destroed. Removing $hostIp from known hosts "
  ssh-keygen -f ~/.ssh/known_hosts -R $hostIp 2>&1 | tee log/local.log

  cd ../..
  inf "local terraform" "Kube host destroyed"
  databaseUpdate
}

uploadWorkFiles() {
  find . -name ".DS_Store" -delete
  scpAddress="root@$hostIp:/tmp/work"

  inf "engine\t" "Creating $scpAddress/bin"
  sshConnector 'terraformHost' 'cd ../tmp/ && mkdir work && cd work && mkdir bin && mkdir tf'

  inf "integration\t" "Performing upload to $scpAddress"
  scp -rB bin $scpAddress
  scp -rB deploy_lib $scpAddress
  scp -rB tf/cluster $scpAddress/tf
  scp -rB tf/terraform.auto.tfvars $scpAddress/tf
  scp -rB tf $scpAddress
  scp -rB Local.sh $scpAddress
  #todo: if err
  inf "engine\t" "All files uploaded"
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
