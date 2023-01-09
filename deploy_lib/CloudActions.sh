#!/bin/bash

uploadZip() {
  hostIp=$(python3 ./deploy_lib/py_lib/getIpByName.py 'terraformHost')
  inf "upload zip" "Performing zip upload to ${hostIp}"
  scpAddress="root@"$hostIp":/tmp"
#  scp work.zip scpAddress 1>/dev/null && res='work.zip'
  isError=$?
  if [[ $res == "work.zip" ]]; then
    inf "upload zip" "Uploaded work zip successfully"
  else
    err "upload zip" "Zip upload failed"
  fi

  unzipper $hostIp
}

unzipper() {
  echo $1
  echo $(pwd)

  ssh root@$1 "cd ../tmp && ls"
}
sshConnectionStart() {

}

sshConnectionEnd() {
  exit
}

