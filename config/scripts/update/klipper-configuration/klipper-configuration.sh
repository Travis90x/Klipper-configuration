if [ ! -d ~/Klipper-configuration/ ]; then git clone https://github.com/Travis90x/Klipper-configuration.git ~/Klipper-configuration/; fi
cd ~/Klipper-configuration && git pull && cd -
cp -r ~/Klipper-configuration/* ~/printer_data/config
sudo chown -R $USER: ~/printer_data
sudo find ~/printer_data/config/config/scripts/ -type f -name "*.sh" -exec chmod +x {} \;

echo Creating update script
sudo rm /usr/local/bin/klipper-configuration-update
sudo ln -s ~/printer_data/config/config/scripts/update/klipper-configuration/klipper-configuration.sh /usr/local/bin/klipper-configuration-update


echo Creating webcam scripts
sudo rm /usr/local/bin/webcam_check
sudo ln -s ~/printer_data/config/config/scripts/webcam/webcam_check.sh /usr/local/bin/webcam_check
sudo rm /usr/local/bin/webcam_start
sudo ln -s ~/printer_data/config/config/scripts/webcam/webcam_start.sh /usr/local/bin/webcam_start
sudo rm /usr/local/bin/webcam_stop
sudo ln -s ~/printer_data/config/config/scripts/webcam/webcam_stop.sh  /usr/local/bin/webcam_stop


echo Creating backup scripts
sudo rm /usr/local/bin/printer.cfg-backup
sudo ln -s ~/printer_data/config/config/scripts/backup/printer.cfg-backup.sh /usr/local/bin/printer.cfg-backup
sudo rm /usr/local/bin/printer.cfg-backup
sudo ln -s ~/printer_data/config/config/scripts/backup/printer.cfg-backup_clean.sh /usr/local/bin/printer.cfg-backup_clean


echo Creating Log CPU scripts
sudo rm /usr/local/bin/LOG_CPU_START
sudo ln -s ~/printer_data/config/config/scripts/cpu/LOG_CPU_START.sh /usr/local/bin/LOG_CPU_START
sudo rm /usr/local/bin/LOG_CPU_STOP
sudo ln -s /home/pi/printer_data/config/config/scripts/cpu/LOG_CPU_STOP.sh /usr/local/bin/LOG_CPU_STOP
sudo rm /usr/local/bin/LOG_CPU_CLEAN
sudo ln -s /home/pi/printer_data/config/config/scripts/cpu/LOG_CPU_CLEAN.sh /usr/local/bin/LOG_CPU_CLEAN

echo Creating Input Shaping scripts
sudo rm /usr/local/bin/generate-shaper-graph
sudo ln -s /home/pi/printer_data/config/config/scripts/input-shaping/generate-shaper-graph.sh /usr/local/bin/generate-shaper-graph
sudo rm /usr/local/bin/generate-shaper-graph-x
sudo ln -s /home/pi/printer_data/config/config/scripts/input-shaping/generate-shaper-graph-x.sh /usr/local/bin/generate-shaper-graph-x
sudo rm /usr/local/bin/generate-shaper-graph-y
sudo ln -s /home/pi/printer_data/config/config/scripts/input-shaping/generate-shaper-graph-y.sh /usr/local/bin/generate-shaper-graph-y
sudo rm /usr/local/bin/generate-belt-tension-graph
sudo ln -s /home/pi/printer_data/config/config/scripts/input-shaping/generate-belt-tension-graph.sh /usr/local/bin/generate-belt-tension-graph
