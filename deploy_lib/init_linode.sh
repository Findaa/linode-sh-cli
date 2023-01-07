#!/bin/bash

inf(){
  echo "init_linode \t $(date) \t INFO: $1"
}

err(){
  echo "\n init_linode \t $(date) \t ERROR: $1"
}

main() {
  createWorkDir 2> /dev/null
  isError=$?
  if [[ $isError -eq 1 ]]; then
    dir="./work"
    if [ -d "$dir" ]; then
      inf "Work directory already exists. Deleting its contents"
      rm -rf ./work/*
    else
      err "Can not create work directory. Directory does not exist"
    fi
  fi
  inf "Success - Create work directory"

  copyTerraformFiles 2> /dev/null
  isError=$?
  if [[ $isError -eq 1 ]]; then
    err "Can not copy terraform folder. Check if working directory exists or root folder is OK"
    echo $(pwd)
    exit
  fi
  inf "Success - Copy terraform files to work directory"
}

createWorkDir() {
  mkdir work
}

copyTerraformFiles() {
  cp -r ./tf ./work
}

executeTerraformCommands() {
  terraform init
  terraform plan
  terraform apply -auto-approve
}

testFunction() {
  touch test.txt
}

main
