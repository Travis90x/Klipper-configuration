#!/bin/bash 
fdisk -l | grep -oE '/dev/sd[a-z][0-9]+'
