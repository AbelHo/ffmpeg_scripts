#!/bin/bash

if [ $# -eq 1 ]; then
    folder=$1
else
    folder=.
fi

find $folder -print0 -maxdepth 0 | while IFS= read -r -d '' file
do 
    echo -----------------------------
    echo "$file"
    echo -----------------------------
    tail $file
    echo 
done