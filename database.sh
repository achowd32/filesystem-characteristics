#!/bin/bash

# THIS SCRIPT MAPS A FILETREE STARTING AT A GIVEN NODE TO A SQLITE DATABASE

# create database
rm fsdb.db
touch fsdb.db
sqlite3 fsdb.db 'CREATE TABLE fsgraph(identifier int, name text, parent text);'

# read from incoming stream
id=0
while IFS= read filename; do
    parent="$(dirname "$filename")"
    sqlite3 fsdb.db \
        -cmd '.parameter init' \
        -cmd ".parameter set :id $id" \
        -cmd ".parameter set :filename '$filename'" \
        -cmd ".parameter set :parent '$parent'" \
        "INSERT INTO fsgraph values(:id, :filename, :parent);"
    ((id++))
done < <(cd "$1"; find . -exec echo {} \;)
