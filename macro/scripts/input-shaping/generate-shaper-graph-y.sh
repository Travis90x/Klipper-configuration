#!/bin/bash
## set -x #echo on # don't activate if use script in klipper
# set -u  pipefail
# INPUT SHAPING Y
# COPY THIS FILE IN /HOME/PI/KLIPPER/SCRIPT/

# Take last files
FILENAME=$(ls -Art /tmp/resonances_y_*.csv | tail -n 1)

ALLCSV=/tmp/resonances_y_*.csv

DATE=$(date +'%Y-%m-%d-%H%M%S')

OUTDIR=~/printer_data/config/input_shaper
 if [ ! -d "${OUTDIR}" ]; then
    mkdir "${OUTDIR}"
    chown $USER:$USER "${OUTDIR}" 
fi
chown $USER:$USER ~/klipper/scripts/


## File renamed with date from last two CSV files
~/klipper/scripts/calibrate_shaper.py $FILENAME -o "${OUTDIR}/shaper_calibrate_y_$DATE.png"

## Replace old png
cp "${OUTDIR}/shaper_calibrate_y_$DATE.png" "${OUTDIR}/2_shaper_calibrate_y.png"

mv /tmp/resonances_y_*.csv "${OUTDIR}/" > /dev/null 2>&1

mv $ALLCSV "${OUTDIR}/" > /dev/null 2>&1
