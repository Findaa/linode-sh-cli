#!/bin/bash

. deploy_lib/CloudActions.sh
. deploy_lib/DatabaseManager.sh
. deploy_lib/Log.sh

runCloud() {
  export infoColor="36;49m"
  echo '\n'
  echo "\033[$infoColor Cloud host menu\033[0m "
  PS3="Choice:    "
  options=("Create cluster" "Delete cluster" "List nodes" "Quit cloud back to local")
  select opt in "${options[@]}"; do
    case $opt in
    "Create cluster")
      kubeClusterDeployFromCloud
      databaseUpdate
      cloudOptionsPrint
      ;;
    "Delete cluster")
      kubeClusterDestroyFromCloud
      databaseUpdate
      cloudOptionsPrint
      ;;
    "List nodes")
      kubeNodesFetchFromCloud
      databaseUpdate
      cloudOptionsPrint
      ;;
    "Quit cloud back to local")
      sh deploy_lib/Local.sh
      ;;
    esac
  done
}

cloudOptionsPrint() {
  echo "\n1.) Create cluster\t3.) List nodes\n2.) Delete cluster\t4.) Quit cloud back to local"
}

runCloud
