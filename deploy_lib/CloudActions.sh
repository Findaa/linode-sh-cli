#!/bin/bash

. ./deploy_lib/DatabaseManager.sh

uploadWorkFiles() {
  hostIp=$(getNodeIpByName 'terraformHost')
  scpAddress="root@$hostIp:/tmp"

  inf "upload" "Performing upload to $scpAddress"
#  scp -r deploy_lib $scpAddress 2>1 1>log/scp_log.txt && res='true'
#  scp -r tf/cluster $scpAddress 2>1 1>log/scp_log.txt && res='true'
#  scp -r worker.sh $scpAddress 2>1 1>log/scp_log.txt && res='true'
  scp -r deploy_lib $scpAddress && res='true'
  scp -r tf/cluster $scpAddress && res='true'
  scp -r worker.sh $scpAddress && res='true'
  #todo: if err
  inf "upload" "All files uploaded"

}

installTerraformRemoteHost () {
  sshConnector 'terraformHost' installTerraform
}

#installTerraform() {
#
#}

#If used with 1 arg will open ssh, with 2 args will execute ssh param.
#arg1 <- label of node | arg2 <- potential sh command/script
sshConnector() {
  hostIp=$(getNodeIpByName $1)
  inf "connector" $hostIp
  inf "connector" $2
  ssh -o 'StrictHostKeyChecking accept-new' root@$hostIp $2 2>1 1>log/connection.log

  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "ssh connector" "err"
  else
    inf "ssh connector" "gucci"
  fi
}

sshConnectionEnd() {
  exit
}

