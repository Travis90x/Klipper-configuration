#!/bin/bash
OUTFILE=~/printer_data/config/input_shaper/1_shaper_calibrate_x.png
OUTLINK=../server/files/config/input_shaper/1_shaper_calibrate_x.png
 if [ ! -d "${OUTDIR}" ]; then
    mkdir "${OUTDIR}"
    chown $USER:$USER "${OUTDIR}" 
fi

title='<b><p style="font-weight-bold; margin:0; color:white">FILE:'${OUTFILE}'</p></b>'
info="<a style=color:cyan>Click image to download<a style=color:#fb15ff> or right click for options.</a></a>"
img='<a href="'${OUTFILE}'" target="_blank" ><img src="'${OUTFILE}'" width="100%"></a>'
console_out="$title\n$info\n$img"
echo -e "$console_out"
