#! /bin/bash

if [ $# -ne 2 ]; then
    echo "There must be exactly two parameters." >&2
    exit 1
fi

if [ ! -d "$1" -o ! -d "$2" ]; then
    echo "Both parmeters must be existing directories." >&2
    exit 2
fi

if [ ! -f "$1/db" -o ! -d "$1/packages" ]; then
    echo "The repository folder does not follow the structure requirements." >&2
    exit 3
fi

if [ ! -f "$2/version" -o ! -d "$2/tree" ]; then
    echo "The packege folder does not follow the structure requirements." >&2
    exit 4
fi

random_name="$(openssl rand -base64 15).tar.xz"
if ! tar cJf "$random_name" "$2/tree"; then
    echo "There was a problem creating the archive." >&2
    exit 5
fi

package_name="$(basename "$2")"
version="$(cat $2/version)"
sum="$(sha256sum "$random_name" | cut -d " " -f 1)"

egrep -n "^${package_name}-$version " "$1/db" | cut -d ":" -f 1 | while read line_num; do 
   if ! (rm "$1/packages/$(head -n "$line_num" "$1/db" | tail -n 1 | cut -d " " -f 2).tar.xz" && sed -i "${line_num}d" "$1/db"); then
       echo "There was a problem removing the old package." >&2
       exit 7
   fi
done

echo "${package_name}-$version $sum" >> "$1/db"

if ! mv "$random_name" "$1/packages/${sum}.tar.xz"; then
    echo "There was a problem moving the archive in the packages folder." >&2
    exit 6
fi


