#
# Rock on free cafe or library wifi that impose horrendous limit on your network usage.
# It spoofs your device's MAC address, run it once to turn on, twice to turn off. You get a random MAC addr everytime. 
# So to extend on an existing spoofing session, turn off, then turn on again. 
# Winston Lin 林大爷 @ 2023
# 
# Tested on MacOS 11, 12. 
# Note: You can always reboot your Mac and everything will be reset

#!/bin/bash
REAL_MAC_ADDR_FILE="/tmp/real_mac_addr.conf"
CUR_MAC=$(ifconfig en0 | grep ether | cut -c 8-)

if [ -f $REAL_MAC_ADDR_FILE ]; then 
    REAL_MAC_ADDR=$(cat $REAL_MAC_ADDR_FILE)
else 
    REAL_MAC_ADDR=$CUR_MAC
    echo "${REAL_MAC_ADDR}" > "$REAL_MAC_ADDR_FILE"
fi 

if [ $# -lt 1 ]; then 
    echo "Usage : $0 show/go/help"
    exit 0
fi

if [ "$1" == "show" ]; then
    if [ $CUR_MAC != $REAL_MAC_ADDR ]; then
        echo "Currently spoofing"
    else 
        echo "Not currently spoofing"
    fi 
    echo "Current MAC is: $CUR_MAC"
elif [ "$1" == "go" ]; then 
    # disconnect the wifi
    if [ $CUR_MAC = $REAL_MAC_ADDR ]; then
        MAC_TO_SET=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//')
        echo "Original $CUR_MAC spoofing $MAC_TO_SET"
    else
        MAC_TO_SET=$REAL_MAC_ADDR
        echo "Reverted back to $REAL_MAC_ADDR"
    fi
    sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -z
    sudo ifconfig en0 lladdr $MAC_TO_SET
else
    echo "Usage : $0 show/go/help"
fi 