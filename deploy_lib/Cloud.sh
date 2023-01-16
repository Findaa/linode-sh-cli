#!/bin/bash

. deploy_lib/CloudHandler.sh
. deploy_lib/DatabaseManager.sh
. deploy_lib/Log.sh
. deploy_lib/const.sh
. deploy_lib/Menus.sh

runCloud() {
  infoColor="36;49m"
  echo '\n'
  echo "\033[$infoColor Cloud host menu\033[0m "
  PS3="Choice:    "
  options=("Create cluster" "Delete cluster" "List nodes" "Quit cloud back to local")
  select opt in "${options[@]}"; do
    case $opt in
    "Create cluster")
      kubeClusterDeployFromCloud
      printCloudMenu
      ;;
    "Delete cluster")
      kubeClusterDestroyFromCloud
      printCloudMenu
      ;;
    "List nodes")
      kubeNodesFetchFromCloud
      printCloudMenu
      ;;
    "Quit cloud back to local")
      inf "cloud" "Closing connection"
      echo "\n"
      infoColor="1;35m"
      printLocalMenu
      exit
      ;;
    esac
  done
}

runCloud
