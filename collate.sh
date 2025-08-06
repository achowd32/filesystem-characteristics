#!/bin/bash

# THIS SCRIPT COLLATES IMPORTANT FILESYSTEM PROPERTIES

# set properties
shopt -s nullglob

# set overall property variables
num_nodes=0

avg_depth=0
max_depth=0

avg_fanout=0
max_fanout=0

# read filenames and collate properties
while IFS= read filename; do
    # set variables for clarity
    filepath="$1$filename" # relative filepath from script

    # calculate and save depth
    depth=$(echo "$filename" | grep -o "/" | wc -l | tr -d ' ')
    ((avg_depth += depth))

    # calculate and save fanout
    fanout=0
    [[ -d "$filepath" ]] && fanout=$(files=("$filepath"/*); echo ${#files[@]})
    ((avg_fanout += fanout))

    # add to number of nodes
    ((num_nodes++))

    # format and print
    printf '|%-30s| ' "${filename}"
    printf '%-10s| ' "DEPTH: ${depth}"
    printf '%-10s|\n' "FANOUT: ${fanout}"
done < <(cd "$1"; find . -exec echo {} \;)

# print overall properties
echo "AVERAGE DEPTH: $(echo "scale=4; $avg_depth / $num_nodes" | bc -l)"
echo "AVERAGE FANOUT: $(echo "scale=4; $avg_fanout / $num_nodes" | bc -l)"
