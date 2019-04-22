#!/bin/bash
declare -i i=0

while [[ i -lt ${#BASH_REMATCH[@]} ]]
do
    [[ ${#BASH_REMATCH[i]} -gt 0 ]] && echo 'MATCH['${i}']: ^'${BASH_REMATCH[i]}'$'
    ((i++))
done

echo 'cnt(MATCH[])='${#BASH_REMATCH[@]}

