#!/bin/bash

cd "$(dirname "$0")"

while read image; do
    if docker inspect "${image}_fsc" >/dev/null 2>&1 ; then
        echo "Container '${image}_fsc' exists"
        docker start -a "${image}_fsc"
    else
        echo "Setting up container '${image}_fsc'"
        docker run --name "${image}_fsc" -v .:/fsdb "${image}" bash -c \
            "cd fsdb; ./collate.sh /usr/"
    fi
done < images.txt
