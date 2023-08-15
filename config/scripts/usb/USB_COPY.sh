#!/bin/bash
destination_folder="/home/pi/printer_data/gcodes"
for gcodes_folder in /media/pi/*/gcodes; do
    if [[ "$gcodes_folder" =~ ^/media/pi/[^/]+/gcodes$ ]]; then
        cp -r "$gcodes_folder"/* "$destination_folder"
    fi
done
