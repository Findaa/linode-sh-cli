#!/bin/bash

WORKDIR="./work"
export LINODE_CLI_TOKEN="949505f61e40135f06bf04fe99c699d15b008f8ca2a6e430d437fd3b752735ab"

. deploy_lib/LocalActions.sh
. deploy_lib/CloudActions.sh
. deploy_lib/DatabaseManager.sh
. deploy_lib/Log.sh

main() {
  appUser=$(whoami)
  inf "local application" "App started by ${appUser}"
  echo '\n'
  echo "\033[1;35mLocal host menu\033[0m "
  PS3="Choice:      "
  options=("Create kube host" "Create cluster" "Delete host" "Delete cluster" "List nodes" "Quit" "Enter Cloud")
  select opt in "${options[@]}"; do
    case $opt in
    "Create kube host")
      kubeHostCreate
      optionsPrint
      ;;
    "Create cluster")
      kubeClusterDeploy
      databaseUpdate
      optionsPrint
      ;;
    "Delete host")
      kubeHostDestroy
      databaseUpdate
      optionsPrint
      ;;
    "Delete cluster")
      kubeClusterDestroy
      databaseUpdate
      optionsPrint
      ;;
    "List nodes")
      fetchNodesFormatted
      databaseUpdate
      optionsPrint
      ;;
    "Quit")
#      rm -rf bin
#      rm -rf db
#      rm -rf deploy_lib
      err "HERE" $(pwd)

      break
      exit 420
      ;;
    "Enter Cloud")
      sh deploy_lib/Cloud.sh
      ;;
    *)
      echo "invalid option $REPLY"
      ;;
    esac
  done
}

optionsPrint() {
  echo "\n1.) Create kube host 2.) Create cluster 3.) Delete host 4.) Delete cluster 5.) List nodes 6.) Quit"
}

main
