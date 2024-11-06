#!/usr/bin/bash
#
# (C) Sergii Kulyk aka Saboteur
# King's Bounty save game analyzer
#
[ -z "$1" ] && echo "Please provide filesave name" && exit 1
FILE=$1

FLAG=( " " '*' )
# 25 UNITS, index 0..24
UNITS=( Peasants  Sprites    Militia Wolves  Skeletons
        Zombies   Gnomes     Orcs    Archers Elves
        Pikemen   Nomads     Dwarves Ghosts  Knights
        Ogres     Barbarians Trolls  Cavalry Druids
        Archmages Vampires   Giants  Demons  Dragons )
# 14 spells
SPELLS=( "Clone"  "Teleport"  "Fireball"     "Lightning"   "Freeze"    "Resurrect"    "Turn Undead"
         "Bridge" "Time Stop" "Find Villain" "Castle Gate" "Town Gate" "Instant Army" "Raise Control" )
# 26 Towns
TOWNS=( A B C D E F G H I J K L M N O P Q R S T U V W X Y Z )
TownNames=( "Anomaly"   "Bayside"    "Centrapf"   "Dark Corner" "Elan's Landing" "Fjord"
            "Grimwold"  "Hunterille" "Isla Vista" "Japper"      "King's Haven"   "Lakeview"
            "Midland"   "Nyre"       "Overhere"   "Path's end"  "Quiln Point"    "Riverton"
            "Simpleton" "Topshore"   "Underfoot"  "Vengeance"   "Woods End"      "Xoctan"
            "Yakonia"   "Zaezoizu" )
TownX=( 34 41  9 58  3 46  9 12 57 13 17 17 58 50 57 38 14 29 13  5 58 7 3 51 49 58 )
TownY=( 23 58 39 60 37 35 60  3  5  7 21 44 33 13 57 50 27 12 60 50  4 3 8 28  8 48 )
TownC=( f c a f f c s c c a c c f c a c c c a a f s f c a s ) # continents

echo "Savegame: $FILE"

read -a fkilled<<<"$(od -An -j 3753 -N 2 -t u1 $FILE |head -n1)"	#0xEA9 - 0xEAA   | followers killed
read -a gold<<<"$(od -An -j 4033 -N 2 -t u1 $FILE |head -n1)"		#0xFC1 - 0xFC4   | gold
read -a score<<<"$(od -An -j 4029 -N 2 -t u1 $FILE |head -n1)"		#0xFBD - 0xFBE   | score (never actually used)
echo " Followers killed: $(( ${fkilled[0]} * 256 + ${fkilled[1]} )), Gold: $(( ${gold[0]} * 256 + ${gold[1]} )), Score(?): $(( ${score[0]} * 256 + ${score[1]} ))"

read FX FY AX AY SX SY<<<$(od -An -j 2420 -N 6 -t u1 $FILE |head -n1)
read OCX OCY OFX OFY OAX OAY OSX OSY<<<$(od -An -j 2426 -N 8 -t u1 $FILE |head -n1)
read CA FA AA SA CO FO AO SO<<<$(od -An -j 40 -N 8 -t u1 $FILE |head -n1)	#0x028 - 0x02B is continent available, 0x02C - 0x02F  is orb found

printf "  Continentia: orb:[%2d %2d]%s  pass:[%2d %2d]%s\n" "$OCX" "$OCY" "${FLAG[$CO]}" "$FX" "$FY" "${FLAG[$FA]}"
printf "  Forestria:   orb:[%2d %2d]%s  pass:[%2d %2d]%s\n" $OFX $OFY "${FLAG[$FO]}" $AX $AY "${FLAG[$AA]}"
printf "  Archipelia:  orb:[%2d %2d]%s  pass:[%2d %2d]%s\n" $OAX $OAY "${FLAG[$AO]}" $SX $SY "${FLAG[$SA]}"
printf "  Saharia:     orb:[%2d %2d]%s\n\n" $OSX $OSY "${FLAG[$SO]}"

# 0x056 - 0x06F   | spell sold in towns
read R U P A T L S C Q M X O E K B N D I G J V H F Y W Z <<<$(od -An -j 86 -N 26 -t u1 $FILE -w 26|head -n1)
cnt=0
for cnt in {0..12}; do
  cnt1=$((cnt+13))
  printf " %s:%02dx%02d %-14s %-13s | %s:%02dx%02d %-11s %-13s\n" ${TownC[$cnt]} ${TownX[$cnt]} ${TownY[$cnt]} "${TownNames[$cnt]}" "${SPELLS[${!TOWNS[$cnt]}]}" ${TownC[$cnt1]} ${TownX[$cnt1]} ${TownY[$cnt1]} "${TownNames[$cnt1]}" "${SPELLS[${!TOWNS[$cnt1]}]}"
done

#0xE4A - 0xE75   | dwelling N troop
#0xE76 - 0xEA1   | dwelling N population
#0x992 - 0x9E9   | dwelling coords (2 bytes each, 11 per continent)
read -a dwelling<<<$(od -An -j 3658 -N 44 -t u1 -w44 $FILE|head -n1)
read -a population<<<$(od -An  -j 3702 -N 44 -t u1 -w44 $FILE|head -n1)
read -a dcoord<<<$(od -An  -j 2450 -N 88 -t u1 -w88 $FILE|head -n1)
printf "\nContinentia:                Forestria:                 Archipelia:                Saharia:\n"
#for cnt in {0..43}; do
function print_unit(){
  coordx=$(( $1 * 2 ))
  coordy=$(( $1 * 2 + 1 ))
  if [ "${dcoord[$coordx]}" == "0" ]; then
    printf "                          $2"
  else
    printf " %-10s (%03d) [%02d:%02d] $2" "${UNITS[${dwelling[$1]}]}" "${population[$1]}" "${dcoord[$coordx]}" "${dcoord[$coordy]}"
  fi
}
for i in {0..10}; do
  print_unit $i " |"
  print_unit "$(( $i + 11 ))" "|"
  print_unit "$(( $i + 22 ))" "|"
  print_unit "$(( $i + 33 ))" '\n'
done