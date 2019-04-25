#!/bin/bash
typeset -r FILE_NODE_REL_LIST=$1
typeset -r FILE_HEADER=$2
typeset -r FILE_FOOTER=$3
typeset line
typeset -r -a list=($(< ${FILE_NODE_REL_LIST}))
typeset -a -i open
typeset -i closePos=0
typeset -i pos
typeset ext
typeset attr
typeset code

echo $(< ${FILE_HEADER})

get_position()
{
    echo ${line%%\;*}
}

get_attribute()
{
    local x=${line#*\;*\;}

    echo ${x%%\;*}
}

get_extension()
{
    local x=${line#*\;*\;*\;}

    echo ${x%%\;*}
}

get_code()
{
    local x=${line#*\;*\;*\;*\;\"}
    x=${x%\"\;}
    x=${x//\"\"/\"}

    echo ${x} | sed 's/$%\([a-zA-Z0-9_][a-zA-Z0-9_]*\)/$astetTmplVars["\1"]/g'
}

open_json_element()
{
    echo -n "\$astetJson[] = ['pos' => ${pos}, "

    [[ ${attr} ]] && echo -n "'attr' => '${attr}', "
    [[ ${ext} ]] && echo -n "'ext' => '${ext}', "
}

write_to_json()
{
    open_json_element
    [[ ${code:0:1} == '=' ]] && echo "'replace' => ${code:1}];"
    [[ ${code:0:1} == '<' ]] && echo "'before' => ${code:1}];"
    [[ ${code:0:1} == '>' ]] && echo "'after' => ${code:1}];"
}

increment_open()
{
    (( open[${list[${pos}]}]++ ))
}

increment_close()
{
    while (( open[${closePos}]-- > 0 ))
    do
        echo "}"
    done
    (( closePos++ ))
}

close()
{
    while [[ ${closePos} -lt $1 ]]
    do
        increment_close
    done
}

while IFS=; read -r line
do
    pos=$(get_position)
    ext=$(get_extension)
    attr=$(get_attribute)
    code=$(get_code)

    case ${ext} in
        'loop')
            increment_open
            open_json_element && echo "'loop' => true];"
            echo "foreach (${code}) {"
            ;;
        'if')
            increment_open
            echo "\$astetNextIf = true == ${code};"
            open_json_element && echo "'if' => \$astetNextIf];"
            echo "if (\$astetNextIf) {"
            ;;
        *)
            case ${code:0:1} in
                '='|'<'|'>') write_to_json ;;
                *) echo ${code} ;;
            esac
            ;;
    esac

    close ${pos}

done

close ${#list[@]}

echo $(< ${FILE_FOOTER})
