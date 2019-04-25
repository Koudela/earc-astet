#!/bin/bash
typeset nodeNumber
typeset nextNode
typeset nextParameter
typeset -a nodeNames
typeset attributeName
typeset extensionName

add_dynamic_content()
{
    echo -n $((${nodeNumber}-1))\;
    echo -n ${nodeNames[$((${#nodeNames[@]} - 1))]}\;
    echo -n ${attributeName}\;
    echo -n ${extensionName}\;
    echo -n \"
    echo -n ${nextParameter} | sed -r 's/"/""/'
    echo \"\;
}
