#! /bin/bash 

# Problem 20. 2017-IN-01

if [ $# -ne 3 ]; then
        echo "Usage: '$0' <filename> <string 1> <string 2>" >&2
        exit 1
fi

if [ ! -f "$1" ]; then 
        echo "The given file must be regular." >&2
        exit 2
fi

if [ -z "$2" -o -z "$3" ]; then
        echo "The given strings must not be empty." >&2
        exit 3
fi

value1="$(egrep "^$2=" $1 | cut -d "=" -f 2 | sed "s/ /\n/g")"
value2="$(egrep "^$3=" $1 | cut -d "=" -f 2 | sed "s/ /\n/g")"

if [ ! -z "$value2" ]; then
        unique="$(comm -13 <(echo "$value1") <(echo "$value2") | tr "\n" " ")"
        line_number="$(egrep -n "^$3=" "$1" | cut -d ":" -f 1)"
        # echo "$unique \n Line number: $line_number"
        sed -Ei "${line_number}"'s/^([^=]+)=(.*)$/\1='"${unique}"'/' "$1"
else
        echo "The second string is not present as a key. \n Doing noting."
fi 
