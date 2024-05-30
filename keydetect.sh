#!/usr/bin/env bash
# Special keypress detection
while true; do
  printf "hexdump: [$(echo -n "$keypress"|hexdump -e '8/1 "%02X ""\t"" "' -e '8/1 "%c""\n"')], characters: $keycounter\n"
  declare -i keycounter=0
  keypress=""
  read -rsN1 keytap
  while [ -n "$keytap" ]; do
      keycounter+=1
      keypress="${keypress}${keytap}"
      read -sN1 -t 0.01 keytap
  done
done
