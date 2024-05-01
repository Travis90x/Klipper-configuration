#!/bin/bash
mv ~/data1/* ~/IDM
mv ~/data2/* ~/IDM
mv ~/data3/* ~/IDM
mv ~/data4/* ~/IDM
cd ~/IDM
~/klippy-env/bin/python arg_fit.py
