#!/bin/bash
IFS=
typeset -i -r whitespacePD=4

rm ./output/*

throw_e()
{
    (>&2 echo 'Error in line '${lineNumber}': '$2)
    exit $1
}

################################################################################
#                                                                              #
# Read lines                                                                   #
#                                                                              #
################################################################################
typeset -i lineNumber=0
typeset -i nodeNumber=0

read_lines()
{
    typeset line

    while read -r line
    do
        ((lineNumber++))
        [[ ${line} =~ ^[[:space:]]*($|#) ]] && continue
        extract_line_vars ${line}
        interpret_line_vars
    done

    close_special
    while [[ ${#nodeNames[@]} -gt 0 ]]
    do
        close_node
    done

    ./node_releation_to_list.sh
}

################################################################################
#                                                                              #
# Regex                                                                        #
#                                                                              #
################################################################################
line_regex()
{
    typeset -r contentRegex='^[[:space:]]*(\=)'
    typeset -r depthRegex='^([[:space:]]*(|([0-9]+)[[:space:]]+))'
    typeset -r specialRegex='^[[:space:]]*([-$*\<\>])[[:space:]]'
    typeset -r nodeRegex='([a-z]+)\:'
    typeset -r parameterRegex='(|[[:space:]]([^#]*)(|#.*))$'

    echo '('${contentRegex}'|('${depthRegex}'|'${specialRegex}')'${nodeRegex}')'${parameterRegex}
}

################################################################################
#                                                                              #
# Interpret lines                                                              #
#                                                                              #
################################################################################
typeset -r lineRegex=$(line_regex)
typeset -i nextDepth=-1
typeset nextIsContent=
typeset nextSpecial=
typeset nextNode=
typeset nextParameter=
typeset content=

extract_line_vars()
{
    [[ $1 =~ $lineRegex ]] || throw_e 1 'Line could not be matched.'

    nextIsContent=${BASH_REMATCH[2]}
    nextDepth=$(new_depth)
    nextSpecial=${BASH_REMATCH[7]}
    nextNode=${BASH_REMATCH[8]}
    nextParameter=${BASH_REMATCH[10]}
}

new_depth()
{
    [[ ${BASH_REMATCH[6]} ]] && echo ${BASH_REMATCH[6]} || echo $((${#BASH_REMATCH[4]} / ${whitespacePD}))
}

interpret_line_vars()
{
    [[ ${nextIsContent} ]] && content+=${nextParameter} && return
    [[ ${nextSpecial} == \$ ]] && (add_dynamic_content) >> "./output/astet-${nextNode}.csv" && return #js, php, sh
    close_special
    [[ ${nextSpecial} ]] && next_special && return
    interpret_node
}

print_content()
{
    echo -n ${content}
    content=
}

. ./specials/init.sh
. ./specials/dynamic_content.sh

################################################################################
#                                                                              #
# Node                                                                         #
#                                                                              #
################################################################################
typeset -i thisDepth=-1
typeset -a nodeOrigins
typeset -a nodeNames
typeset nodeHeaderIsClosed=true

interpret_node()
{
    if [[ ${thisDepth}+1 -lt ${nextDepth} ]]
    then
        throw_e 2 'Increase of level must not be greater than one.'
    elif [[ ${thisDepth} -eq ${nextDepth} ]]
    then
        close_node
        open_node
    elif [[ ${thisDepth} -lt ${nextDepth} ]]
    then
        close_header_node
        open_node
    else
        while [[ ${#nodeNames[@]} -gt ${nextDepth} ]]
        do
            close_node
        done
        open_node
    fi

    thisDepth=${nextDepth}
}

open_node()
{
    print_spaces ${nextDepth}
    echo -n '<'${nextNode}

    nodeOrigins+=(${nodeNumber})
    nodeNames+=(${nextNode})
    ((nodeNumber++))
    nodeHeaderIsClosed=
}

close_header_node()
{
    [[ ${nodeHeaderIsClosed} ]] && return
    [[ ${#nodeNames[@]} -gt 0 ]] && echo -n '>'
    nodeHeaderIsClosed=true
}

close_node()
{
    typeset -i length=${#nodeNames[@]}

    [[ length -eq 0 ]] && return

    ((--length))

    if [[ ${content} ]]
    then
        close_header_node
        print_content
        echo -n '</'${nodeNames[${length}]}'>'
    elif [[ ${nodeHeaderIsClosed} ]]
    then
        print_spaces $((${#nodeNames[@]} - 1))
        echo -n '</'${nodeNames[${length}]}'>'
    else
        echo -n '/>'
        nodeHeaderIsClosed=true
    fi

    (save_node_rel ${nodeOrigins[${length}]} ${nodeNames[${length}]}) >>  "./output/astet-node-rel.csv";

    unset "nodeNames[${length}]"
    unset "nodeOrigins[${length}]"
}

save_node_rel()
{
    echo $1\;$((${nodeNumber}-1))\;$2\;
}

print_spaces()
{
    typeset -i i=0

    echo ''

    while [[ ${i} -lt $1 ]];
    do
        echo -n ' '
        ((i++))
    done
}

################################################################################
#                                                                              #
# MAIN                                                                         #
#                                                                              #
################################################################################

read_lines
