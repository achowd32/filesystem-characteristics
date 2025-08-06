#!/bin/bash

# THIS SCRIPT MAPS A FILETREE STARTING AT A GIVEN NODE TO A SQLITE DATABASE

# create database
[[ -e fsdb.db ]] && rm fsdb.db; touch fsdb.db # clean and (re)create database
sqlite3 fsdb.db 'CREATE TABLE fsgraph(id int, name text, parent text, depth int, fanout int);'

# read from incoming stream
id=0
while IFS= read filename; do
    # set variables for clarity
    filepath="$1$filename" # relative filepath from script

    # get parent name
    parent="$(dirname "$filename")"

    # calculate and save depth
    depth=$(echo "$filename" | grep -o "/" | wc -l | tr -d ' ')

    # calculate and save fanout
    fanout=0
    [[ -d "$filepath" ]] && fanout=$(files=("$filepath"/*); echo ${#files[@]})

    sqlite3 fsdb.db \
        -cmd ".parameter init" \
        -cmd ".parameter set :id $id" \
        -cmd ".parameter set :filename '$filename'" \
        -cmd ".parameter set :parent '$parent'" \
        -cmd ".parameter set :depth '$depth'" \
        -cmd ".parameter set :fanout '$fanout'" \
        "INSERT INTO fsgraph values(:id, :filename, :parent, :depth, :fanout);"
    ((id++))
done < <(cd "$1"; find . -exec echo {} \;)

# print final results
sqlite3 fsdb.db -cmd ".mode table" "SELECT * FROM fsgraph"
echo -n "AVERAGE DEPTH: "; sqlite3 fsdb.db "SELECT AVG(depth) FROM fsgraph"
echo -n "AVERAGE FANOUT: "; sqlite3 fsdb.db "SELECT AVG(fanout) FROM fsgraph"
