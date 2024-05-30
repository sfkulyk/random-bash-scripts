#!/usr/bin/env bash

function usage(){
    echo "Syntax:"
    echo " $0 -h"
    echo " $0 --help"
    echo " $0 --start <environment>"
    exit $1
}
[ $# -eq 0 ] && usage 0
OPTSTR=$(getopt --name $0 --options -hs: --longoptions help,start: -- $@)
[ $? -ne 0 ] && usage 0
eval set -- "$OPTSTR" # this will expand longoptions to full names (like --hel to --help)

while true; do
    case "$1" in
      -h|--help)  usage 0;;
      -s|--start) ENV="$2"
                  shift 2;;
      --)         break;;
      *)          usage 1;;
  esac
done

echo "Starting program with environment: [$ENV], the rest of arguments is: [$@]"
