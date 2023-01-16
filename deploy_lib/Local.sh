#!/bin/bash

. deploy_lib/LocalHandler.sh
. deploy_lib/CloudHandler.sh
. deploy_lib/DatabaseManager.sh
. deploy_lib/Log.sh
. deploy_lib/const.sh

main() {
  export infoColor="1;35m"
  databaseUpdate
  echo '\n'
  fetchNodesFormatted
  echo "\033[$infoColor Local host menu\033[0m "
  PS3="Choice:      "
  options=("Create kube host" "Create cluster" "Delete host" "Delete cluster" "List nodes" "Quit" "Enter Cloud")
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
