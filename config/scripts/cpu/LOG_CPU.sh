#!/bin/bash

MaxFileSize=204800
DaysToKeep=3
log_dir="/home/pi/printer_data/config/config/scripts/logs/CPU"
log_file="$log_dir/CPU.txt"


mkdir -p "$log_dir"
touch "$log_file"

echo -e "\n Fecha:"$(date) >> "$log_file"
echo -e "\n Uptime: "$(uptime) >> "$log_file"
ps -e -o pcpu,pmem,args --sort=pcpu | tail >> "$log_file"

file_size=$(du -b "$log_file" | tr -s '\t' ' ' | cut -d' ' -f1)

if [ $file_size -gt $MaxFileSize ]; then
    timestamp=$(date +%s)
    mv "$log_file" "$log_dir/CPU.txt.$timestamp"
    gzip "$log_dir/CPU.txt.$timestamp"
    touch "$log_file"
    # Rimozione dei vecchi file
    find "$log_dir" -name "CPU.txt.*" -type f -mtime +$DaysToKeep -delete
fi
