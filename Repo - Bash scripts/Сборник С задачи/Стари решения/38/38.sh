#! /bin/bash

if [ $# -ne 2 ]; then
    echo "There must be exactly two arguments." >&2
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "The source folder must exist." >&2
    exit 2
fi

if ! mkdir "$2"; then
    echo "The destination folder could not be created." >&2
    exit 3
fi

mkdir "$2/images"

clear_string() {
    IFS="\n"
    read data
    sed "s/^[[:space:]]*//g;s/[[:space:]]*$//g" <<< "$data" | tr -s '[[:space:]]'
}

dir_create() {
    if [ ! -d "$1" ]; then
        if ! mkdir -p "$1"; then
            echo "There was a problem creating $1." >&2
            exit 4
        fi
    fi
}

while read line; do
    name="$(basename "$line")"
    title="$(sed "s/([^)]*)//g" <<< "$name" | sed -E "s/\.[^\.]+$//g" | clear_string)"
    album="$(egrep -o "\([^\)]*\)[^\(\)]*\.[^.]+$" <<< "$name" | egrep -o "^\([^\)]*\)" | tr -d '()' | clear_string)"

    if [ -z "$album" ]; then
        album="misc"
    fi

    date="$(stat "$line" --printf "%y" | cut -c -10)"
    hsh="$(sha256sum "$line" | cut -c -16)"

    # echo "Line: $line"
    # echo "Name: $name"
    # echo "Title: $title"
    # echo "Album: $album"
    # echo "Date: $date"
    # echo "Hash: $hsh"
    
    dest="$2/images/$hsh.jpg"
    cp "$line" "$dest" 

    dir_create "$2/by-date/$date/by-album/$album/by-title/"
    ln -s "$dest" "$2/by-date/$date/by-album/$album/by-title/$title.jpg"
    
    dir_create "$2/by-date/$date/by-title"
    ln -s "$dest" "$2/by-date/$date/by-title/$title.jpg"

    dir_create "$2/by-album/$album/by-date/$date/by-title/"
    ln -s "$dest" "$2/by-album/$album/by-date/$date/by-title/$title.jpg"

    dir_create "$2/by-album/$album/by-title"
    ln -s "$dest" "$2/by-album/$album/by-title/$title.jpg"

    dir_create "$2/by-title/"
    ln -s "$dest" "$2/by-title/$title.jpg"



done < <(find "$1" -type f)
