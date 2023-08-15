#!/bin/bash

for usb_device in /dev/sd[a-z][0-9]*; do
    device_name=$(basename "$usb_device")
    udisksctl mount -b "$usb_device"
done
