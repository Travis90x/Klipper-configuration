echo "$1" | sudo apt-get install android-tools-adb
cd ~/KlipperScreen/scripts
rm launch_KlipperScreen.sh
cp sample-android-adb.sh launch_KlipperScreen.sh
sudo chmod +x launch_KlipperScreen.sh
sudo service KlipperScreen restart
