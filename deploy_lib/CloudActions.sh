#!/bin/bash

. ./deploy_lib/DatabaseManager.sh

uploadWorkFiles() {
  hostIp=$(getNodeIpByName 'terraformHost')
  scpAddress="root@$hostIp:/tmp"

  inf "upload" "Performing upload to $scpAddress"
#  scp -r deploy_lib $scpAddress 2>1 1>log/scp_log.txt && res='true'
#  scp -r tf/cluster $scpAddress 2>1 1>log/scp_log.txt && res='true'
#  scp -r worker.sh $scpAddress 2>1 1>log/scp_log.txt && res='true'
#  scp -r bin $scpAddress 2>1 1>log/scp_log.txt && res='true'
  find . -name ".DS_Store" -delete
  scp -r deploy_lib $scpAddress && res='true'
  scp -r tf/cluster $scpAddress && res='true'
  scp -r worker.sh $scpAddress && res='true'
  scp -r bin $scpAddress && res='true'
  #todo: if err
  inf "upload" "All files uploaded"
}

installTerraformRemoteHost () {
  sshConnector 'terraformHost' 'cd ../tmp/bin && mv terraform /usr/local/bin/ && terraform -v'
}

#If used with 1 arg will open ssh, with 2 args will execute ssh param.
#arg1 <- label of node | arg2 <- potential sh command/script
sshConnector() {
  hostIp=$(getNodeIpByName $1)
  inf "connector" "Performing ssh connection to "$hostIp " with command " $2
  ssh -o 'StrictHostKeyChecking accept-new' root@$hostIp $2

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "ssh connector" "Error connecting with ssh"
  else
    inf "ssh connector" "Success connecting with ssh"
  fi
}

sshConnectionEnd() {
  exit
}

