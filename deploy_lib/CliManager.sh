#!/bin/bash
#MOST LIKELY temp file. Either temp or used to call py functions reading data.


getKubeHostIp() {
  #todo: temporary solution, use file reader
  #example: linode-cli linodes list --json --pretty >> db.txt then get the db.txt and read values from here
  #This would work fine if we only had 1 linode. But we need to diff between labels to get correct IP.
  #Alternative is to skip python completely and use linode-cli linodes list --text >> db.txt -> then read from here.
  hostIp=$(linode-cli linodes list --json | python3 -mjson.tool | grep -A1 'ipv4' | sed 's/."ipv4": //' | sed 's/"//g' | sed 's/\[//g')
  echo hostIp
}

listNodes() {
  echo $(linode-cli linodes list)
}

getKubeHostName() {

}

