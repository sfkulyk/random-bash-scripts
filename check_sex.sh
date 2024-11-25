#!/usr/bin/env bash
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo "=           Calculate child sex by Platon Number methodic           ="
echo "= Based on calculating the age of blood on the moment of conception ="
echo "=        Attantion! This is just a fun program! No warranty!        ="
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo ""
read -p "Enter father birthday: "
[ -z "$REPLY" ] && REPLY="10/7/1976"
mbirth="$(date -d "$REPLY" "+%s")"
echo "Father: $(date -d "$REPLY" "+%Y-%B-%d")"
echo ""
read -p "Enter mother birthday: "
[ -z "$REPLY" ] && REPLY="06/28/1982"
fbirth="$(date -d "$REPLY" "+%s")"
echo "Mother: $(date -d "$REPLY" "+%Y-%B-%d")"
echo ""
read -p "Enter (planning) the day of conception: "
#[ -z "$REPLY" ] && REPLY="$(date)"
[ -z "$REPLY" ] && REPLY="02/28/2017"
etime="$(date -d "$REPLY" "+%s")"
echo "Conception: $(date -d "$REPLY" "+%Y-%B-%d")"

mage=$(( $etime-$mbirth ))
fage=$(( $etime-$fbirth ))
mblood=$(( $mage / 60 / 60 / 24 ))
fblood=$(( $fage / 60 / 60 / 24 ))

while [ $mblood -gt 1460 ]; do mblood=$(( $mblood-1460 )); done # 1460 = 4 years
while [ $fblood -gt 1095 ]; do fblood=$(( $fblood-1095 )); done # 1095 = 3 years

diff=$(( $fblood-$mblood )) && diff=${diff/#-}
echo "=-=-=-= Rezult =-=-=-="
if [ $fblood -gt $mblood ]; then
  echo " Girl!"
  echo " Mother's blood is younger then father's blood by $diff day(s)"
else
  echo " Boy!"
  echo " Father's blood is younger then mother's blood by $diff day(s)"
fi
echo "Details:"
tmp=$(( $mblood-1095 ))
echo " Mother - age: $(($mage/60/60/24)) days, blood age: $mblood, next refresh in ${tmp/#-} days"
tmp=$(( $fblood-1460 ))
echo " Father - age: $(($fage/60/60/24)) days, blood age: $fblood, next refresh in ${tmp/#-} days"
