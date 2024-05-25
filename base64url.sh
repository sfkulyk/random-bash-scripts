#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "provide file name to encode"
  exit 1
fi
base64 $2 <$1 | tr '/+' '_-' | tr -d '='
