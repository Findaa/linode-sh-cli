#!/bin/bash

source ./deploy_lib/init_linode.sh
WORKDIR="./work"

printOptions() {
  echo "1.) Create kube host 2.) Create cluster 3.) Delete host 4.) Delete cluster 5.)Quit"
}

main() {
  PS3='Please enter your choice: '
  options=("Create kube host" "Create cluster" "Delete host" "Delete cluster" "Quit")
  select opt in "${options[@]}"; do
    case $opt in
    "Create kube host")
      prepareEnv
      engineCreate
      printOptions
      ;;
    "Create cluster")
      echo "you chose choice 2"
      ;;
    "Delete host")
      engineDestroy
      printOptions
      ;;
    "Delete cluster")
      echo "you chose choice $REPLY which is $opt"
      ;;
    "Quit")
      break
      ;;
    *) echo "invalid option $REPLY" ;;
    esac
  done
}

main
