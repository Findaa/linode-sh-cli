#!/bin/bash

fetchNodesPlaintext() {
  linode-cli linodes list --text
}

fetchNodesFormatted() {
  linode-cli linodes list
}

fetchNodesJson() {
  linode-cli linodes list --json --pretty
}
upsertNodeDb() {
  cat /dev/null > db/db.txt
  fetchNodesPlaintext > db/db.txt
  fetchNodesJson > db/db.json
  cd db
  cp db.txt db.csv

#  Linux version
#  sed -i "s/[[:blank:]]\{1,\}/ /g" db.csv
#  OSX version
  sed -i '' 's/[[:blank:]]\{1,\}/;/g' db.csv

  inf "database update" "Database updated sucessfuly."
  cd ..
}

getNodeIpByName() {
 python3 ./deploy_lib/py_lib/getIpByName.py $1
}

databaseUpdate() {
  if [ $(basename "`pwd`") == "work" ]; then
    upsertNodeDb
  else
    err "database update" "Can not find a database directory. Does work folder exist?"
    echo $(pwd)
  fi
}