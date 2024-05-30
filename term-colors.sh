#!/usr/bin/env bash
echo "Terminal: ${TERM}"
# foreground: 1-255
# background: 38-48
for bgcolor in {40..48} ; do
    echo -en "\nBackground ${bgcolor}: "
    for fgcolor in {30..40} ; do
        printf "\e[${bgcolor};5;${fgcolor}m %3d\e[0m" ${fgcolor}
    done
done
echo