#!/bin/bash

cd "$(dirname "$0")"

touch fs_results.csv
echo ' Distribution,# Files,# Dirs,# Symlinks,Avg. Depth,Max. Depth,Avg. Fanout,Max. Fanout,Avg. Filesize (Bytes),Max. Filesize (Bytes),Avg. Disk Usage (Blks),Max. Disk Usage (Blks)' > fs_results.csv

while read image; do
    echo -n "${image}," >> fs_results.csv
    if docker inspect "${image}_fsc" >/dev/null 2>&1 ; then
        echo "Container '${image}_fsc' exists"
        docker start -a "${image}_fsc"
    else
        echo "Setting up container '${image}_fsc'"
        docker run --name "${image}_fsc" -v .:/fsdb "${image}" bash -c \
            "cd fsdb; ./collate.sh /usr/"
    fi
done < images.txt
