#!/bin/bash

. ./deploy_lib/DatabaseManager.sh

uploadWorkFiles() {
  hostIp=$(getNodeIpByName 'terraformHost')
  scpAddress="root@$hostIp:/tmp"
  find . -name ".DS_Store" -delete

  inf "cloud" "Adding $hostIp to the list of known hosts. This may take a moment as connection needs to be confirmed first."
  sshCommand="ssh -o 'StrictHostKeyChecking accept-new' root@$hostIp 'ls'"
  inf "cloud" "Using $sshCommand"
  eval $sshCommand

  inf "cloud" "Performing upload to $scpAddress"
#  scp -r deploy_lib $scpAddress 2>1 1>log/scp_log.txt && res='true'
#  scp -r tf/cluster $scpAddress 2>1 1>log/scp_log.txt && res='true'
#  scp -r worker.sh $scpAddress 2>1 1>log/scp_log.txt && res='true'
#  scp -r bin $scpAddress 2>1 1>log/scp_log.txt && res='true'
  scp -r deploy_lib $scpAddress && res='true'
  scp -r tf/cluster $scpAddress && res='true'
  scp -r tf/variables.tf $scpAddress/cluster && res='true'
  scp -r worker.sh $scpAddress && res='true'
  scp -r bin $scpAddress && res='true'

  #todo: if err
  inf "cloud" "All files uploaded"
}

installTerraformRemoteHost () {
  inf "cloud" "Installing terraform for kube host"
  sshConnector 'terraformHost' 'cd ../tmp/bin && mv terraform /usr/local/bin/ && terraform -v'
}

kubeClusterDeploy() {
  inf "local terraform" "Starting to deploy kube workers"
  cd tf/cluster
  terraform init
  terraform plan -var-file="../terraform.auto.tfvars"
  terraform apply -var-file="../terraform.auto.tfvars" -auto-approve
  cd ../..
}

kubeClusterDestroy() {
  cd tf/cluster
  terraform destroy -auto-approve

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "local" "Linode engine could not be deleted. Probably the work folder was deleted manually. Remove cloud host from linode UI or with cli"
  else
    inf "local" "Remote kubernetes host removed."
  fi

  cd ../..
}

#If used with 1 arg will open ssh, with 2 args will execute ssh param.
#arg1 <- label of node | arg2 <- potential sh command/script
sshConnector() {
  hostIp=$(getNodeIpByName $1)
  inf "connector" "Performing ssh connection to $hostIp with command $2"
  sshCommand="ssh root@$hostIp '$2'"
  eval $sshCommand

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "connector" "Error connecting with ssh"
  else
    inf "connector" "Success connecting with ssh"
  fi
}

sshConnectionEnd() {
  exit
}

