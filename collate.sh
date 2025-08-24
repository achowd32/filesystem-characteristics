#!/bin/bash

# THIS SCRIPT COLLATES IMPORTANT FILESYSTEM PROPERTIES

# get command line options
verbose=0
while getopts v opts; do
    case $opts in
    v) verbose=1;;
    esac
done
shift $((OPTIND-1))

# set properties
shopt -s nullglob

# verbose print function
vprint() {
    # | filename | depth | fanout | filesize (b) | disk (blocks) |
    printf '|%-60s| ' "$1"
    printf '%-10s| ' "$2"
    printf '%-10s| ' "$3"
    printf '%-10s| ' "$4"
    printf '%-10s|\n' "$5"
}
[[ $verbose -eq 1 ]] && vprint "filename" "depth" "fanout" "filesize" "disk (blk)"

# set overall property variables
num_nodes=0

num_files=0; num_dirs=0; num_syml=0

avg_depth=0; max_depth=0

avg_fanout=0; max_fanout=0

avg_fsize=0; max_fsize=0

avg_disk=0; max_disk=0

# read filenames and collate properties
while IFS= read name; do
    # set variables for clarity
    filepath="$1$name" # relative filepath from script

    # add to number of files/directories/symlinks
    [[ -f "$filepath" ]] && ((num_files++))
    [[ -d "$filepath" ]] && ((num_dirs++))
    [[ -L "$filepath" ]] && ((num_syml++))

    # calculate and save depth
    depth=$(echo "$name" | grep -o "/" | wc -l | tr -d ' ')
    ((avg_depth += depth))
    max_depth=$((max_depth > depth ? max_depth : depth))

    # calculate and save fanout
    fanout=0
    [[ -d "$filepath" ]] && fanout=$(files=("$filepath"/*); echo ${#files[@]})
    ((avg_fanout += fanout))
    max_fanout=$((max_fanout > fanout ? max_fanout : fanout))

    # calculate and save filesize
    fsize=NA
    if [[ -f "$filepath" ]]; then
        fsize=$(ls -l "$filepath" | awk '{print $5}')
        ((avg_fsize += fsize))
        max_fsize=$((max_fsize > fsize ? max_fsize : fsize))
    fi

    # calculate and save disk blocks
    disk=NA
    if [[ -f "$filepath" ]]; then
        disk=$(du "$filepath" | awk '{print $1}')
        ((avg_disk += disk))
        max_disk=$((max_disk > disk ? max_disk : disk))
    fi 

    # add to number of nodes
    ((num_nodes++))

    # format and print
    [[ $verbose -eq 1 ]] && vprint "$name" "$depth" "$fanout" "$fsize" "$disk"
done < <(cd "$1"; find . -exec echo {} \;)

# print overall properties
echo -n "${num_files}," >> fs_results.csv
echo -n "${num_dirs}," >> fs_results.csv
echo -n "${num_syml}," >> fs_results.csv

awk -v ad="$avg_depth" -v nn="$num_nodes" 'BEGIN{printf "%.4f,", ad/nn}' >> fs_results.csv
echo -n "${max_depth}," >> fs_results.csv

awk -v af="$avg_fanout" -v nn="$num_nodes" 'BEGIN{printf "%.4f,", af/nn}' >> fs_results.csv
echo -n "${max_fanout}," >> fs_results.csv

awk -v af="$avg_fsize" -v nn="$num_files" 'BEGIN{printf "%.4f,", af/nn}' >> fs_results.csv
echo -n "${max_fsize}," >> fs_results.csv
 
awk -v ad="$avg_disk" -v nn="$num_files" 'BEGIN{printf "%.4f,", ad/nn}' >> fs_results.csv
echo -n "${max_disk}" >> fs_results.csv
