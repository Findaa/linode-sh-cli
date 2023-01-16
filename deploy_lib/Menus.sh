#!/bin/bash

printLocalMenu() {
  echo "\033[$infoColor Local host menu\033[0m "
  echo "\n1.) Create kube host\t4.) Delete cluster\t7.) Enter Cloud \n2.) Create cluster\t5.) List nodes\t\t8.) test\n3.) Delete host\t\t6.) Quit "
}

printCloudMenu() {
  echo "\033[$infoColor Cloud host menu\033[0m "
  echo "\n1.) Create cluster\t3.) List nodes\n2.) Delete cluster\t4.) Quit cloud back to local"
}
