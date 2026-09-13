#!/bin/bash
echo ls /dev/v4l/by-id/*
ls /dev/v4l/by-id/*
echo v4l2-ctl --list-devices
v4l2-ctl --list-devices

