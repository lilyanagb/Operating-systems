#! /bin/bash

N=10
temp_file="$(mktemp "XXXXXXX.temp")"

while [ $# -gt 0 ]; do
    if [ "$1" = "-n" ]; then
        if [[ -z "$2" || ! "$2" =~ ^[0-9]+$ ]]; then
            echo "After -n there must be a numeric value."
            exit 1
        else
            N=$2
        fi

        shift 2
        continue
    fi

    tail -n "$N" "$1" | awk -F " " -v id="$(basename "$1" | sed "s/\.log$//g")" '
        { 
            printf("%s %s %s",$1,$2,id); 
            for (i = 3; i <= NF; ++i) printf(" %s",$i); 
            print; 
        }' >> "$temp_file"
    shift
done

sort -k 1.1nr -k 1.6nr -k 1.9nr -k 2.2nr -k 2.4nr -k 2.6nr "$temp_file"

if ! rm "$temp_file"; then
    echo "There was a problem removing the temp file." >&2
    exit 2
fi



