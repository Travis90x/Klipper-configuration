#!/bin/bash
## set -x #echo on # don't activate if use script in klipper
# set -u  pipefail
# INPUT SHAPING X
# COPY THIS FILE IN /HOME/PI/KLIPPER/SCRIPT/

# Take last files
FILENAME=$(ls -Art /tmp/resonances_x_*.csv | tail -n 1)

ALLCSV=/tmp/resonances_x_*.csv

DATE=$(date +'%Y-%m-%d-%H%M%S')

OUTDIR=~/printer_data/config/input_shaper
 if [ ! -d "${OUTDIR}" ]; then
    mkdir "${OUTDIR}"
    chown $USER:$USER "${OUTDIR}" 
fi
chown $USER:$USER ~/klipper/scripts/


## File renamed with date from last two CSV files
~/klipper/scripts/calibrate_shaper.py $FILENAME -o "${OUTDIR}/shaper_calibrate_x_$DATE.png"

## Replace old png
cp "${OUTDIR}/shaper_calibrate_x_$DATE.png" "${OUTDIR}/1_shaper_calibrate_x.png"

mv /tmp/resonances_x_*.csv "${OUTDIR}/" > /dev/null 2>&1

mv $ALLCSV "${OUTDIR}/" > /dev/null 2>&1
