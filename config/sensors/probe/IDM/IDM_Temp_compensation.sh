#!/bin/bash
mv -f ~/klipper/data1 ~/klipper/data2 ~/klipper/data3 ~/klipper/data4 ~/IDM/ 2>/dev/null
echo "Files moved in IDM: data1, data2, data3, data4."
cd ~/IDM
~/klippy-env/bin/python arg_fit.py
mv -f ~/IDM/fit_result.png ~/printer_data/config/IDM_result/fit_result.png 2>/dev/null
echo "File fit_result.png moved in printer_data/config/IDM_result."
echo "Rendering complete."

