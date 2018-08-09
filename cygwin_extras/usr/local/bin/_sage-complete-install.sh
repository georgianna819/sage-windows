#!/bin/sh
export PATH=/usr/bin:/bin
for filename in /etc/fstab.d/*; do
    dos2unix "$filename"
    chmod 600 "$filename"
done

rm -f /usr/local/bin/_sage-complete-install.sh
