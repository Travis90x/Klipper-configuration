#!/bin/bash
## set -x #echo on # don't activate if use script in klipper
# set -u  pipefail
# INPUT SHAPING
# COPY THIS FILE IN /HOME/PI/KLIPPER/SCRIPT/

# Take last files
FILENAMEX=$(ls -Art /tmp/calibration_data_x_*.csv | tail -n 1)
FILENAMEY=$(ls -Art /tmp/calibration_data_y_*.csv | tail -n 1)

ALLCSV=/tmp/calibration_data_*.csv

DATE=$(date +'%Y-%m-%d-%H%M%S')

OUTDIR=~/printer_data/config/input_shaper
 if [ ! -d "${OUTDIR}" ]; then
    mkdir "${OUTDIR}"
    chown $USER:$USER "${OUTDIR}" 
fi
chown $USER:$USER ~/klipper/scripts/


## File renamed with date from last two CSV files
~/klipper/scripts/calibrate_shaper.py $FILENAMEX -o "${OUTDIR}/shaper_calibrate_x_$DATE.png"
~/klipper/scripts/calibrate_shaper.py $FILENAMEY -o "${OUTDIR}/shaper_calibrate_y_$DATE.png"

## Replace old png
cp "${OUTDIR}/shaper_calibrate_x_$DATE.png" "${OUTDIR}/1_shaper_calibrate_x.png"
cp "${OUTDIR}/shaper_calibrate_y_$DATE.png" "${OUTDIR}/2_shaper_calibrate_y.png"

mv /tmp/calibration_data_x_*.csv "${OUTDIR}/" > /dev/null 2>&1
mv /tmp/calibration_data_y_*.csv "${OUTDIR}/" > /dev/null 2>&1

mv $ALLCSV "${OUTDIR}/" > /dev/null 2>&1
