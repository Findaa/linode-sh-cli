#!/bin/bash

main() {
  PS3='Please enter your choice: '
  options=("Check cluster status" "Create new cluster" "Delete cluster" "Quit")
  select opt in "${options[@]}"; do
    case $opt in
    "Initialise deployments")
      echo "you chose choice 1"
      ;;
    "Create new cluster")
      echo "you chose choice 2"
      ;;
    "Manage clusters")
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


