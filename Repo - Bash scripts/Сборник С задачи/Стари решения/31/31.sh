#! /bin/bash 

if [ $# -ne 2 ]; then
    echo "There must be exactly two parameters." >&2
    exit 1
fi

if [ ! -f "$1" -o ! -r "$1" ]; then
    echo "Please, provide an existing and readable file." >&2
fi

if [ -f "$2" ]; then
    read -p "$2 already exists. Do you want to remove it? [y/n]" choice
    
    while [ "$choice" != "n" -a "$choice" != "y" ]; do
        read -p "Please, type \"y\" or \"n\" " choice
    done

    if [ "$choice" = "n" ]; then
        exit 0
    else
        if ! rm "$2"; then
            echo "There was a problem removing the old file." >&2
            exit 2
        fi
    fi
fi

if ! cp "$1" "$2"; then
    echo "There was a problem creating the result file." >&2
    exit 3
fi

sed -E "s/^[0-9]+,//g" "$1" | sort | uniq -c | awk '
    {
        if ($1 > 1) 
            for (i=2; i<=NF; ++i) 
                printf("%s ",$i); 
    } 
    END { 
        printf "\n"

    }' | while read line; do 
            egrep "$line" "$1" | sort -t ":" -nbrk 2 | head -n +2 | cut -d ":" -f 1 | xargs -I {} sed -i "{}d" "$2"
done

