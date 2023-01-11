#!/bin/bash

. deploy_lib/CloudActions.sh
. deploy_lib/DatabaseManager.sh
. deploy_lib/Log.sh

runCloud() {
  infoColor="36;49m"
  echo '\n'
  echo "\033[$infoColor Cloud host menu\033[0m "
  echo $infoColor
  PS3="Choice:    "
  options=("Create cluster" "Delete cluster" "List nodes" "Quit cloud back to local")
  select opt in "${options[@]}"; do
    case $opt in
    "Create cluster")
      kubeClusterDeployFromCloud
      databaseUpdate
      optionsPrint
      ;;
    "Delete cluster")
      kubeClusterDestroyFromCloud
      databaseUpdate
      optionsPrint
      ;;
    "List nodes")
      fetchNodesFormattedCloud
      databaseUpdate
      optionsPrint
      ;;
    "Quit cloud back to local")
      sh deploy_lib/Worker.sh
      ;;
    esac
  done
}

runCloud
