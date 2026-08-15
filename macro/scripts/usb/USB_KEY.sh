#!/bin/bash
echo Partitions on USB:
fdisk -l | grep -oE '/dev/sd[a-z][0-9]+'
