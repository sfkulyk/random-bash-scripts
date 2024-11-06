#!/bin/bash

#
# need to install "sox" to generate and concatenate sounds
# need to install "ffmpeg" to convert wav to mp3 (you can skip this)
#

# Configuration, freq, length of dot, dash and space
freq=800
dot=0.05
dash=0.15
pause1=0.05
pause2=0.2
message="$1"

# init, just once to create sound files
if [ ! -e morse/lsep.wav ]; then
  mkdir morse
  sox -n -r 44100 -c 1 morse/lsep.wav synth $pause1 vol 0
  sox -n -r 44100 -c 1 morse/wsep.wav synth $pause2 vol 0
  sox -n -r 44100 -c 1 morse/dot.wav synth $dot sine $freq vol 0.5
  sox -n -r 44100 -c 1 morse/dash.wav synth $dash sine $freq vol 0.5
fi

# english, ukrainian, russsian letters
declare -A morse
morse=( ["A"]=".-"    ["B"]="-..."  ["C"]="-.-."  ["D"]="-.."   ["E"]="."    ["F"]="..-." ["G"]="--."
        ["H"]="...."  ["I"]=".."    ["J"]=".---"  ["K"]="-.-"   ["L"]=".-.." ["M"]="--"   ["N"]="-."
        ["O"]="---"   ["P"]=".--."  ["Q"]="--.-"  ["R"]=".-."   ["S"]="..."  ["T"]="-"    ["U"]="..-"
        ["V"]="...-"  ["W"]=".--"   ["X"]="-..-"  ["Y"]="-.--"  ["Z"]="--.."

        ["А"]=".-"    ["Б"]="-..."  ["Ц"]="-.-."  ["Д"]="-.."   ["Е"]="."    ["Ф"]="..-."  ["Г"]="--." ["Ґ"]="--."
        ["Х"]="...."  ["І"]=".."    ["Й"]=".---"  ["К"]="-.-"   ["Л"]=".-.." ["М"]="--"    ["Н"]="-."  ["Ї"]=".---."
        ["О"]="---"   ["П"]=".--."  ["Ш"]="----"  ["Р"]=".-."   ["С"]="..."  ["Т"]="-"     ["У"]="..-" ["Щ"]="--.--"
        ["В"]="...-"  ["Ж"]=".--"   ["Ь"]="-..-"  ["И"]="-.--"  ["З"]="--.." ["Є"]="..-.." ["Ч"]="---." ["Ю"]="..--" ["Я"]=".-.-"
        ["Ъ"]="--.--" ["Ы"]="-.--"  ["Ё"]="."

        ["1"]=".----" ["2"]="..---" ["3"]="...--" ["4"]="....-" ["5"]="....."
        ["6"]="-...." ["7"]="--..." ["8"]="---.." ["9"]="----." ["0"]="-----"
        [" "]=" " )

flist=""
text=""

for (( i=0; i<${#message}; i++ )); do
    char="${message:$i:1}"
    char="${char^^}"  # uppercase
    code="${morse[$char]}"

    for (( j=0; j<${#code}; j++ )); do
        symbol="${code:$j:1}"
        if [[ "$symbol" == "." ]]; then
            flist="$flist dot.wav lsep.wav"
            text="${text}●"
        elif [[ "$symbol" == "-" ]]; then
            flist="$flist dash.wav lsep.wav"
            text="${text}-"
        fi
    done
    # pause between letters
    flist="$flist wsep.wav"
            text="$text  "
done
rm morse.wav morse.mp3 morse.txt
sox $flist -t wavpcm morse.wav >/dev/null 2>&1
ffmpeg -i morse.wav morse.mp3 >/dev/null 2>&1
echo "$text" > morse.txt
