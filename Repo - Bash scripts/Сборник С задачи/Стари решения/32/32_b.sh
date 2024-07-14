#! /bin/bash 

IFS="\n"
min="none"
max_sum=""

temp_file="$(mktemp "XXXXXX.temp")"
if [ -z "$temp_file" ]; then
    echo "There was a problem creating the temp file" >&2
    exit 1
fi

sumi() {
    sed "s/-//g;s/./\0+/g" <<< "$1" | sed "s/+$//g" | bc
}

while read line; do
    if [[ "$line" =~ ^-?[0-9]+$ ]]; then
        echo "$line" >> "$temp_file"

        if [ "$min" = "none" ]; then
            min="$line"
            max_sum="$(sumi "$line")"
        fi
        
        if [ "$line" -lt "$min" -a "$(sumi $line)" -ge "$max_sum" ]; then
            min="$line"
            max_sum="$(sumi "$line")"
        fi
    fi
done

while read line; do
    if [ "$line" -le "$min" -a "$(sumi "$line")" -eq "$max_sum" ]; then
        echo "$line"
    fi
done < "$temp_file" | sort | uniq

if ! rm "$temp_file"; then
    echo "There was a problem removing the temp file" >&2
    exit 2
fi

