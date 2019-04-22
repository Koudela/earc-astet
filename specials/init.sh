#!/bin/bash
typeset nextNode
typeset nextSpecial
typeset nextParameter
typeset attributeName
typeset extensionName

next_special() {
    case ${nextSpecial} in
        '-') open_attribute;;
        '*') open_extension;; #loop, if, elif, else, on*
    esac
}

close_special() {
    [[ ${attributeName} ]] && close_attribute
    [[ ${extensionName} ]] && close_extension
}

. ./specials/attribute.sh
. ./specials/extension.sh
