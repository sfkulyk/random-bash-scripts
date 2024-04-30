#!/bin/bash
echo " Kiev 10
Kharkov 20
Kiev 15
Sumy 10
Kiev 25
Sumy 1
Odessa 5"| awk '{city[$1]+=$2}END{for(item in city){print item" "city[item]}}'