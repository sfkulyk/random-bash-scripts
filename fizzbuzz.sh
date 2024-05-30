#!/usr/bin/env bash
for i in {1..100}; do
   [ $((i%3)) -eq 0 ] && a[$i]="Fizz"
   [ $((i%5)) -eq 0 ] && a[$i]+="Buzz"
   printf "${a[$i]:-$i} "
done
