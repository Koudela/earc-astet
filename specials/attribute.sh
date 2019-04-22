#!/bin/bash
typeset attributeName
typeset nextParameter
typeset nextNode

open_attribute()
{
    content+=${nextParameter}
    attributeName=${nextNode}
}

close_attribute()
{
    if [[ ${content} ]]
    then
        echo -n ' '${attributeName}'="'
        print_content
        echo -n '"'
    fi

    attributeName=
}
