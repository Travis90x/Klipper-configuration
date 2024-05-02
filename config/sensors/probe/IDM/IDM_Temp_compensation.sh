#!/bin/bash
cp -f ~/klipper/data1 ~/klipper/data2 ~/klipper/data3 ~/klipper/data4 ~/IDM/
cd ~/IDM
~/klippy-env/bin/python arg_fit.py
mkdir -p ~/printer_data/config/IDM_result
cp -f ~/IDM/fit_output.png ~/printer_data/config/IDM_result/fit_output.png
