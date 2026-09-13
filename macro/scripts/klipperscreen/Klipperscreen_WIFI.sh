echo "$1" | sudo -S apt-get install android-tools-adb
cd ~/KlipperScreen/scripts
rm launch_KlipperScreen.sh
cp sample-android-adb.sh launch_KlipperScreen.sh
sudo chmod +x launch_KlipperScreen.sh
touch launch_KlipperScreen.sh
# ${2} is your IP from the macro
echo 'DISPLAY=${2}:0 $KS_XCLIENT' > /home/pi/KlipperScreen/scripts/launch_KlipperScreen.sh
sudo service KlipperScreen restart
