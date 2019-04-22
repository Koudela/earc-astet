#!/bin/bash
typeset -r -a list=($(< ./output/astet-node-rel.list))

echo $(< ./templates/header.php)

getPosition()
{
    echo ${1%%\;*}
}

getAttribute()
{
    local x=${1#*\;*\;}

    echo ${x%%\;*}
}

getExtension()
{
    local x=${1#*\;*\;*\;}

    echo ${x%%\;*}
}

getCode()
{
    local x=${1#*\;*\;*\;*\;\"}
    x=${x%\"\;}
    echo ${x//\"\"/\"}
}

while IFS=; read -r line
do
    ext=$(getExtension ${line})
    case ext in
        'loop') ;;
        'if') ;;
        'elif') ;;
        'else') ;;
        *)
    esac
    attribute=$(getAttribute ${line})
    code=$(getCode ${line})
    case ${code:0:1} in
        '='|'<'|'>')
            echo -n "\$astetJson['p"$(getPosition ${line})"']"
            [[ ${attribute} ]] && echo -n "['a'][${attribute}]"
            [[ ${ext} ]] && echo -n "['e'][${ext}]"
            [[ ${code:0:1} == '=' ]] && echo "['r']="${code:1}
            [[ ${code:0:1} == '<' ]] && echo "['b']="${code:1}
            [[ ${code:0:1} == '>' ]] && echo "['a']="${code:1}
            ;;
        *) echo ${code} ;;
    esac



done < ./output/astet-php.csv

echo $(< ./templates/footer.php)

