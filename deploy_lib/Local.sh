#!/bin/bash

. deploy_lib/LocalHandler.sh
. deploy_lib/CloudHandler.sh
. deploy_lib/DatabaseManager.sh
. deploy_lib/Log.sh
. deploy_lib/const.sh
. deploy_lib/Menus.sh

echo $1
if [[ $1 == 'redirect' ]]; then
  echo $1
fi

main() {
  infoColor="1;35m"
  databaseUpdate
  fetchNodesFormatted
  echo '\n'
  echo "\033[$infoColor Local host menu\033[0m "

  PS3="Choice:      "
  options=("Create kube host" "Create cluster" "Delete host" "Delete cluster" "List nodes" "Quit" "Enter Cloud")
  select opt in "${options[@]}"; do
    case $opt in
    "Create kube host")
      kubeHostDeploy
      printLocalMenu
      ;;
    "Create cluster")
      kubeClusterDeploy
      databaseUpdate
      printLocalMenu
      ;;
    "Delete host")
      kubeHostDestroy
      printLocalMenu
      ;;
    "Delete cluster")
      kubeClusterDestroy
      databaseUpdate
      printLocalMenu
      ;;
    "List nodes")
      fetchNodesFormatted
      databaseUpdate
      printLocalMenu
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

main
