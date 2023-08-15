#!/bin/bash
############################################
SD_PATH=~/printer_data/gcodes
############################################

cat ${SD_PATH}/${2} > /tmp/plrtmpA.$$

isInFile=$(cat /tmp/plrtmpA.$$ | grep -c "thumbnail")
if [ $isInFile -eq 0 ]; then
     echo 'M109 S200.0' > ${SD_PATH}/plr.gcode
     cat /tmp/plrtmpA.$$ | sed -e '1,/Z'${1}'/ d' | sed -ne '/ Z/,$ p' | grep -m 1 ' Z' | sed -ne 's/.* Z\([^ ]*\)/SET_KINEMATIC_POSITION Z=\1/p' >> ${SD_PATH}/plr.gcode
else
    sed -i '1s/^/;start copy\n/' /tmp/plrtmpA.$$
    sed -n '/;start copy/, /thumbnail end/ p' < /tmp/plrtmpA.$$ > ${SD_PATH}/plr.gcode
    echo ';' >> ${SD_PATH}/plr.gcode
    echo '' >> ${SD_PATH}/plr.gcode
    echo 'M109 S199.0' >> ${SD_PATH}/plr.gcode
    cat /tmp/plrtmpA.$$ | sed -e '1,/Z'${1}'/ d' | sed -ne '/ Z/,$ p' | grep -m 1 ' Z' | sed -ne 's/.* Z\([^ ]*\)/SET_KINEMATIC_POSITION Z=\1/p' >> ${SD_PATH}/plr.gcode    
fi
echo 'G91' >> ${SD_PATH}/plr.gcode
echo 'G1 Z5' >> ${SD_PATH}/plr.gcode
echo 'G90' >> ${SD_PATH}/plr.gcode
echo 'G28 X Y' >> ${SD_PATH}/plr.gcode

# Extruder Temp
# Bring print_temp in save_variables.cfg
echo 'M104 S'${3} >> ${SD_PATH}/plr.gcode
echo 'M109 S'${3} >> ${SD_PATH}/plr.gcode

# cat /tmp/plrtmpA.$$ | sed '/ Z'${1}'/q' | sed -ne '/\(M104\|M140\|M109\|M190\|M106\)/p' >> ${SD_PATH}/plr.gcode
# cat /tmp/plrtmpA.$$ | sed '/ Z'${1}'/q' | sed -ne '/\(M140\|M190\|M106\)/p' >> ${SD_PATH}/plr.gcode

# Find the last M106 before Z_LOG
cat /tmp/plrtmpA.$$ | sed '/ Z'${1}'/q' | sed -ne '/\(M106\)/p' | head -1 >> ${SD_PATH}/plr.gcode

# Bed Temp
# Find material_bed_temperature after ;End of Gcode
# cat /tmp/plrtmpA.$$ | sed -ne '/;End of Gcode/,$ p' | tr '\n' ' ' | sed -ne 's/ ;[^ ]* //gp' | sed -ne 's/\\\\n/;/gp' | tr ';' '\n' | grep material_print_temperature | sed -ne 's/.* = /M104 S/p' | head -1 >> ${SD_PATH}/plr.gcode
cat /tmp/plrtmpA.$$ | sed -ne '/;End of Gcode/,$ p' | tr '\n' ' ' | sed -ne 's/ ;[^ ]* //gp' | sed -ne 's/\\\\n/;/gp' | tr ';' '\n' | grep material_bed_temperature | sed -ne 's/.* = /M140 S/p' | head -1 >> ${SD_PATH}/plr.gcode
# cat /tmp/plrtmpA.$$ | sed -ne '/;End of Gcode/,$ p' | tr '\n' ' ' | sed -ne 's/ ;[^ ]* //gp' | sed -ne 's/\\\\n/;/gp' | tr ';' '\n' | grep material_print_temperature | sed -ne 's/.* = /M109 S/p' | head -1 >> ${SD_PATH}/plr.gcode
cat /tmp/plrtmpA.$$ | sed -ne '/;End of Gcode/,$ p' | tr '\n' ' ' | sed -ne 's/ ;[^ ]* //gp' | sed -ne 's/\\\\n/;/gp' | tr ';' '\n' | grep material_bed_temperature | sed -ne 's/.* = /M190 S/p' | head -1 >> ${SD_PATH}/plr.gcode


# Extruder lenght G92 Extruder
# cat /tmp/plrtmpA.$$ | sed -e '1,/Z'${1}'/ d' | sed -e '/ Z/q' | tac | grep -m 1 ' E' | sed -ne 's/.* E\([^ ]*\)/G92 E\1/p' >> ${SD_PATH}/plr.gcode
tac /tmp/plrtmpA.$$ | sed -e '/ Z'${1}'[^0-9]*$/q' | tac | tail -n+2 | sed -e '/ Z[0-9]/ q' | tac | sed -e '/ E[0-9]/ q' | sed -ne 's/.* E\([^ ]*\)/G92 E\1/p' >> ${SD_PATH}/plr.gcode
# cat /tmp/plrtmpA.$$ | sed -e '1,/Z'${1}'/ d' | sed -ne '/ Z/,$ p' >> ${SD_PATH}/plr.gcode

echo 'G91' >> ${SD_PATH}/plr.gcode
echo 'G1 Z-5' >> ${SD_PATH}/plr.gcode
echo 'G90' >> ${SD_PATH}/plr.gcode

# Copy from first G1 Z...
tac /tmp/plrtmpA.$$ | sed -e '/ Z'${1}'[^0-9]*$/q' | tac | tail -n+2 | sed -ne '/ Z/,$ p' >> ${SD_PATH}/plr.gcode
/bin/sleep 5
