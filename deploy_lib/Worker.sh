#!/bin/bash

WORKDIR="./work"
export LINODE_CLI_TOKEN="949505f61e40135f06bf04fe99c699d15b008f8ca2a6e430d437fd3b752735ab"

. deploy_lib/LocalActions.sh
. deploy_lib/CloudActions.sh
. deploy_lib/DatabaseManager.sh
. deploy_lib/Log.sh

main() {
  infoColor="1;35m"
  databaseUpdate
  echo '\n'
  echo "\033[$infoColor Local host menu\033[0m "
  PS3="Choice:      "
  options=("Create kube host" "Create cluster" "Delete host" "Delete cluster" "List nodes" "Quit" "Enter Cloud" "test")
  select opt in "${options[@]}"; do
    case $opt in
    "Create kube host")
      kubeHostDeploy
      optionsPrint
      ;;
    "Create cluster")
      kubeClusterDeploy
      optionsPrint
      ;;
    "Delete host")
      kubeHostDestroy
      optionsPrint
      ;;
    "Delete cluster")
      kubeClusterDestroy
      optionsPrint
      ;;
    "List nodes")
      fetchNodesFormatted
      databaseUpdate
      optionsPrint
      ;;
    "Quit")
      rm -rf work/bin
      rm -rf work/db
      rm -rf work/deploy_lib
      break
      exit 420
      ;;
    "Enter Cloud")
      sh deploy_lib/Cloud.sh
#      handshakeWithHost
      echo "a"
      ;;
    "Test")
      export infoColor="1;34m"
      sh deploy_lib/Cloud.sh
      ;;
    *)
      echo "invalid option $REPLY"
      ;;
    esac
  done
}

optionsPrint() {
  echo "\n1.) Create kube host\t4.) Delete cluster\t7.) Enter Cloud \n2.) Create cluster\t5.) List nodes\t\t8.) test\n3.) Delete host\t\t6.) Quit "
}

main
