#! /bin/bash

IFS="\n"
max="none"

temp_file="$(mktemp "XXXXXX.temp")"
if [ -z "$temp_file" ]; then
    echo "There was a problem creating the temp file" >&2
    exit 1
fi

while read line; do
    if [[ "$line" =~ ^-?[0-9]+$ ]]; then
        echo "$line" >> "$temp_file"

        if [ "$max" = "none" ]; then
            max="$line"
        fi
        
        if [ "$line" -gt "$max" ]; then
            max="$line"
        fi
    fi
done

awk -v max="$max" '
    BEGIN {
        if (max < 0) max = max * (-1);
    }
    { 
        temp = $0
        if ($0 < 0) temp = $0 * (-1); 
        if (temp == max) print $0;

    }' "$temp_file" | sort | uniq

if ! rm "$temp_file"; then
    echo "There was a problem removing the temp file" >&2
    exit 2
fi

