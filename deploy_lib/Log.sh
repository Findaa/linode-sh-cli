#!/bin/bash

inf() {
  echo "\033[32;32m[$(date) \t $1] \t INFO:\033[0m $2"
}

err() {
  echo "\033[31;40m[$(date) \t $1] \t ERROR:\033[0m $2"
}

