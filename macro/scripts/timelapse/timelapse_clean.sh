#!/bin/sh
dir="/tmp/timelapse/"
find $dir -name 'frame*.jpg' -size -15k -exec rm {} +
counter=1
files=$(ls $dir*.jpg | sort -V)
echo "$files" | while read file; do
    new_file=$(printf "frame%06d.jpg" $counter)
    if [ "$file" != "$dir$new_file" ]; then
        mv -- "$file" "$dir$new_file"
    fi
    counter=$((counter+1))
done
