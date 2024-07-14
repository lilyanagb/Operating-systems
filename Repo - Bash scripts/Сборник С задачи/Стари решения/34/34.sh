#! /bin/bash

EXTRACTED="./extracted"

if [ $# -ne 1 ]; then
    echo "There must be exactly one parameter." >&2
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Please, provide an existing folder." >&2
    exit 2
fi

folder="$(mktemp -d "XXXXXX.temp")"

clear_folder() {
    if ! rm -rf "$folder/*"; then
        echo "There was a problem clearing the temp folder after extracting $filename" >&2
        exit 5
    fi
}

find "$1" -type f -name "*.tgz" | while read filename; do
    sum="$(sha256sum "$filename" | cut -d " " -f 1)"
    if ! grep -qF "$sum" "$EXTRACTED/db"; then
        echo "$sum" >> "$EXTRACTED/db"

        tar xzf "$filename" -C "$folder" 
        file="$(find "$folder" -name "meow.txt")" 
        
        if [ ! -z "$file" ]; then
            if [ "$(wc -l <<< "$file")" -gt 1 ]; then
                echo "$filename contains meow.txt more than one time. Skipping archive." >&2
                clear_folder
                continue
            fi

            name="$(egrep -o "^[^_]+" <<< "$(basename "$filename")")"
            stamp="$(egrep -o "[0-9]+$" <<< "$(basename "$filename" | sed "s/\.tgz//g")")"
            if ! mv "$file" "$EXTRACTED/${name}_$stamp.txt"; then
                echo "There was a problem moving the meow.txt file." >&2
                exit 4
            fi
        fi
        
        clear_folder
    fi
done

if ! rm -rf "$folder"; then
    echo "There was a problem removing the temp folder." >&2
    exit 3
fi

