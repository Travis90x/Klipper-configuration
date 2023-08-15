sudo apt-get install android-tools-adb
cd ~/KlipperScreen/scripts
rm launch_KlipperScreen.sh
touch launch_KlipperScreen.sh
chmod +x launch_KlipperScreen.sh

# ${1} is your IP from the macro
echo 'DISPLAY=${1}:0 $KS_XCLIENT' > /home/pi/KlipperScreen/scripts/launch_KlipperScreen.sh

sudo service KlipperScreen restart
