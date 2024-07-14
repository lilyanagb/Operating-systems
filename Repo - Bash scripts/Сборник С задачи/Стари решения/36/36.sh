#! /bin/bash

if [ $# -ne 1 ]; then
    echo "There must be exactly one parameter." >&2
    exit 1
fi

if [ ! -f "$1" -o ! -r "$1" ]; then
    echo "Please, provide an existing and readable file." >&2
    exit 2
fi

cut -d " " -f 2 "$1" | sort | uniq -c | sort -r -bk 1 | sed "s/^[[:space:]]*[[:digit:]]* //g" | head -n 3 | while read domain; do
    awk -F " " -v domain="$domain" ' 
            BEGIN {
                http_count=0; non_http_count=0;
            } 
            { 
                if ($2 == domain)  
                    if ($8 == "HTTP/2.0")  ++http_count; 
                    else ++non_http_count;
            }
            END { 
                print domain,"HTTP/2.0:",http_count,"non-HTTP/2.0:",non_http_count
            }
        '  "$1"    
done

awk -F " " '$9 > 302 { print $1 }' "$1" | sort | uniq -c | sort -r -bk 1 | head -n 5

