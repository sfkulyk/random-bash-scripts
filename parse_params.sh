#!/bin/bash

function usage(){
    echo "Syntax:"
    echo " $0 -h"
    echo " $0 --help"
    echo " $0 --start <environment>"
    exit $1
}

[ $# -eq 0 ] && usage 0

OPTSTR=$(getopt --name $0 --options -h --longoptions help,start: -- $@)
if [[ $? -ne 0 ]]; then
    usage 0
fi

eval set -- "${OPTSTR}"
# parse all arguments. 
while true; do
    case "${1}" in
      -h|--help)
        usage 0;;
      --start)
        ENV="${2}"
        shift 2;;
      --)
        break;;
      *)
        usage 1;;
  esac
done

echo "Starting program with environment: ${ENV}"
