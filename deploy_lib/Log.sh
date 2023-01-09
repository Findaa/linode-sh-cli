#!/bin/bash

inf() {
  echo "\033[32;32m[$(date) \t INFO]\033[0m \t $1: $2"
}

err() {
  echo "\033[31;40m[$(date) \t ERROR] \t $1:\033[0m $2"
}

