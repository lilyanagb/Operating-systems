#! /bin/bash

if [ $# -ne 1 ]; then
        echo "Usage: There must be exactly one argument."
        exit 1
fi

if [ ! -d "$1" ]; then
        echo "Usage: The given filepath is not a directory."
        exit 2
fi

# Solution 1
# find -L $1 -type l

# Solution 2
# find "$1" -type l | xargs stat -c %F

# Solution 3
find "$1" -type l | while read line; do
        link_target="$(stat --printf=\"%N\n\" ${line}  | cut -d \' -f 4)"
        echo "${link_target}"

        abs=0
        if [ "$(echo $(link_target) | head -c 1)" = "/" ]; then
                abs=1
        fi

        if [ "${abs}" -eq 1 ]; then
                path_to_target="$(echo "${link_target}")"
        else
                path_to_target="$(dirname "${line}")/${link_target}"
        fi

        if [ ! -e "${path_to_target}" ]; then
                echo "${line}"
        fi
done 
