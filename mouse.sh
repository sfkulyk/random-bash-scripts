#!/bin/bash

let y=0
let x=0
let max_x=120 #$(tput cols)
let max_y=24
let wall=0
let space=""

draw_top() {
    local line[0]='   ###               ###'
    local line[1]='  #####   ## | ##   #####'
    local line[2]='########################### '
    local line[3]='  #######################  '
    local line[4]='     #################   '
    local line[5]='          #######     '
    local line[6]='           ##### '
    local line[7]='             #  '
    local line[8]='              '

    for index in {0..8}; do
        echo "$space${line[$index]}"
    done
}

draw_bottom() { 
    local line[0]='              '
    local line[1]='             #  '
    local line[2]='           ##### '
    local line[3]='          #######     '
    local line[4]='     #################   '
    local line[5]='  #######################  '
    local line[6]='###########################'
    local line[7]='  #####   ## | ##   #####'
    local line[8]='   ###               ###'

    for index in {0..8}; do
        echo "$space${line[$index]}"
    done
}

draw_right() {
    local  line[0]='          #   '
    local  line[1]='          ##  '
    local  line[2]='         #### '
    local  line[3]='       #######'
    local  line[4]='     ######## '
    local  line[5]='     #######  '
    local  line[6]='     ######   '
    local  line[7]='  ##########  '
    local  line[8]='###########-  '
    local  line[9]='  ##########  '
    local line[10]='     ######   '
    local line[11]='     #######  '
    local line[12]='       #######'
    local line[13]='         #### '
    local line[14]='          ##  '
    local line[15]='          #   '

    # Вычисляем сдвиг слева
    space=""
    for ((j = 0; j < $2; j++)) ; do
      space="$space "
    done
    for index in {0..15}; do
        echo "$space${line[$index]}"
    done
}

draw_left() {
    local  line[0]='   # '
    local  line[1]='  ## '
    local  line[2]=' #### '
    local  line[3]='####### '
    local  line[4]=' ######## '
    local  line[5]='  ####### '
    local  line[6]='   ###### '
    local  line[7]='  ########## '
    local  line[8]=' -########### '
    local  line[9]='  ########## '
    local line[10]='   ###### '
    local line[11]='  ####### '
    local line[12]='####### '
    local line[13]=' #### '
    local line[14]='  ## '
    local line[15]='   # '

    # Вычисляем сдвиг слева
    space=""
    for ((j = 0; j < $2; j++)) ; do
      space="$space "
    done
    for index in {0..15}; do
        echo "$space${line[$index]}"
    done
}

move_right() {
    if ((x < max_x - 15))
    then
        ((x++))
    else
        wall=1
    fi

    tput cup $y 0
    draw_right $y $x
}

move_bottom() {
    if ((y < max_y - 8))
    then
        ((y++))
    else
        wall=1
    fi
    
    tput cup $y 0
    draw_bottom $y $x
}

move_left() {
    if (( x > 0 ))
    then
        ((x--))
    else
        wall=1
    fi

    tput cup $y 0
    draw_left $y $x
}

move_top() {
    if (( y > 0 ))
    then
        ((y--))
    else
        wall=1
    fi

    tput cup $y 0
    draw_top $y $x
}

random_choice() {
    RANGE=$1
    number=$RANDOM
    let "number %= $RANGE"
    echo "$number"
}

move() {
    if [ "$1" == 0 ]
    then
        move_right
    fi

    if [ "$1" == 1 ]
    then
        move_left
    fi

    if [ "$1" == 2 ]
    then
        move_top
    fi

    if [ "$1" == 3 ]
    then
        move_bottom
    fi
}

calculate_coords() {
    let vertical=$1

    # Вертикально -> Горизонтально
    if (( vertical > 0))
    then
        x=$((x-8))
        y=$((y+5))

        if (( x < 0 ))
        then
            x=0
        fi

        if (( x + 31 > max_x))
        then
            x=$((max_x-31))
        fi

        if (( y + 8 > max_y))
        then
            y=$((max_y-8))
        fi

    # Горизонтально -> Вертикально
    else
        x=$((x+8))
        y=$((y-5))

        if (( y < 0 ))
        then
            y=0
        fi

        if ((x + 13 > max_x))
        then
            x=$((max_x - 13))
        fi

        if ((y + 17 > max_y))
        then
            y=$((max_y - 17))
        fi
    fi
}

start() {
    current=0
    direction=0
    prevent_direction=0
    clear

    while true; do
        # Calculate dicrection
        if ((current == 20 || wall == 1))
        then
            wall=0
            current=0
            prevent_direction=$direction
            direction=$(random_choice 4)

            if (( direction < 2 && prevent_direction > 1 ))
            then
                calculate_coords 0
            fi

            if (( direction > 1 && prevent_direction < 2 ))
            then
                calculate_coords 1
            fi
            clear
        fi

        # Move
        move $direction
        current=$((current+1))
        /bin/sleep .05
    done
}

start