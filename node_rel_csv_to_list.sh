#!/bin/bash
IFS=\;
typeset -a list

add_to_list()
{
    list[${1}]=${2}
}

while read -r line
do
    add_to_list ${line}
done

echo ${list[@]}
