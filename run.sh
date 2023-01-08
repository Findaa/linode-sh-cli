#!/bin/bash

. ./deploy_lib/LocalActions.sh
. ./deploy_lib/CliManager.sh
. ./deploy_lib/Log.sh

WORKDIR="./work"
export LINODE_CLI_TOKEN="949505f61e40135f06bf04fe99c699d15b008f8ca2a6e430d437fd3b752735ab"

printOptions() {
  echo "1.) Create kube host 2.) Create cluster 3.) Delete host 4.) Delete cluster 5.) List nodes 6.)Quit"
}

main() {
  PS3='Please enter your choice: '
  options=("Create kube host" "Create cluster" "Delete host" "Delete cluster" "List nodes" "Quit")
  select opt in "${options[@]}"; do
    case $opt in
    "Create kube host")
      prepareLocalEnv
      kubeHostCreate
      printOptions
      ;;
    "Create cluster")
      getKubeHostIp
      printOptions
      ;;
    "Delete host")
      kubeHostDestroy
      printOptions
      ;;
    "Delete cluster")
      echo "you chose choice $REPLY which is $opt"
      ;;
    "List nodes")
      listNodes
      printOptions
      ;;
    "Quit")
      break
      ;;
    *) echo "invalid option $REPLY"
      ;;
    esac
  done
}
main
