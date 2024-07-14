#! /bin/bash

if [ $# -ne 2 ]; then
    echo "There must be exactly two parameters." >&2
    exit 1
fi

if [ -f "$1" ]; then
    read -p "$1 already exists, Do you want to replace it? [y/n] " choice
    
    while [ "$choice" != "y" -a "$choice" != "n" ]; do
        read -p "Please, enter \"y\" or \"n\": " choice
    done
    
    if [ "$choice" = "n" ]; then
        exit 1
    else 
        if ! rm "$1"; then
            echo "There was a problem removing $1" >&2
            exit 2
        fi
    fi
fi

if [ ! -d "$2" ]; then
    echo "Please, provide an existing directory." >&2
    exit 3
fi

echo "hostname,phy,vlans,hosts,failover,VPN-3DES-AES,peers,VLAN Trunk Ports,license,SN,key" >> "$1"

# Remember find -name works with globs!
find "$2" -type f -name "*.log" | while read filename; do
    no_space_file="$(sed "s/[[:space:]]//g" "$filename")"
    hostname="$(basename $filename | sed "s/\.log$//g")"
    phy="$(egrep "^MaximumPhysicalInterfaces:[0-9]*$" <<< "$no_space_file" | egrep -o "[0-9]+$")"
    vlans="$(egrep "^VLANs:[0-9]+$" <<< "$no_space_file" | egrep -o "[0-9]+$")"
    hosts="$(egrep "^InsideHosts:" <<< "$no_space_file" | egrep -o "[^:]+$")"
    failover="$(egrep "^Failover:" <<< "$no_space_file" | egrep -o "[^:]+$")"
    vpn="$(egrep "^VPN-3DES-AES:" <<< "$no_space_file" | egrep -o "[^:]+$")"
    total="$(egrep "^\*TotalVPNPeers:[0-9]+$" <<< "$no_space_file" | egrep -o "[0-9]+$")"
    ports="$(egrep "^VLANTrunkPorts:[0-9]+$" <<< "$no_space_file" | egrep -o "[0-9]+$")"
    license="$(egrep "^This platform has (a|an)" "$filename" | sed -E "s/^This platform has (a|an)[[:space:]]*//g;s/[[:space:]]*license.$//g")"
    serial="$(egrep "^SerialNumber:" <<< "$no_space_file" | egrep -o "[^:]+$")"
    key="$(egrep "^RunningActivationKey:" <<< "$no_space_file" | egrep -o "[^:]+$")"
   
    echo "${hostname},${phy},${vlans},${hosts},${failover},${vpn},${total},${ports},${license},${serial},${key}" >> "$1"
done
