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
sudo ln -s ~/printer_data/config/config/scripts/cpu/LOG_CPU_STOP.sh /usr/local/bin/LOG_CPU_STOP
sudo rm /usr/local/bin/LOG_CPU_CLEAN
sudo ln -s ~/printer_data/config/config/scripts/cpu/LOG_CPU_CLEAN.sh /usr/local/bin/LOG_CPU_CLEAN


sudo rm /etc/systemd/system/log_cpu.service
sudo rm /etc/systemd/system/log_cpu.timer
sudo cp -r ~/printer_data/config/config/scripts/cpu/etc_systemd_system/* /etc/systemd/system/
sudo sed -i "s|/home/pi|$(eval echo ~$USER)|g" /etc/systemd/system/log_cpu.service
sed -i 's|/home/pi|'"$HOME"'|g' ~/printer_data/config/config/scripts/cpu/LOG_CPU.sh
sudo systemctl daemon-reload
sudo systemctl enable log_cpu.timer
sudo systemctl enable log_cpu.service
sudo systemctl start log_cpu.timer

echo Creating Input Shaping scripts
sudo rm /usr/local/bin/generate-shaper-graph
sudo ln -s ~/printer_data/config/config/scripts/input-shaping/generate-shaper-graph.sh /usr/local/bin/generate-shaper-graph
sudo rm /usr/local/bin/generate-shaper-graph-x
sudo ln -s ~/printer_data/config/config/scripts/input-shaping/generate-shaper-graph-x.sh /usr/local/bin/generate-shaper-graph-x
sudo rm /usr/local/bin/generate-shaper-graph-y
sudo ln -s ~/printer_data/config/config/scripts/input-shaping/generate-shaper-graph-y.sh /usr/local/bin/generate-shaper-graph-y
sudo rm /usr/local/bin/generate-belt-tension-graph
sudo ln -s ~/printer_data/config/config/scripts/input-shaping/generate-belt-tension-graph.sh /usr/local/bin/generate-belt-tension-graph

echo Creating KlipperScreen scripts
sudo rm /usr/local/bin/Klipperscreen_USB
sudo ln -s ~/printer_data/config/config/scripts/klipperscreen/Klipperscreen_USB.sh /usr/local/bin/Klipperscreen_USB
sudo rm /usr/local/bin/Klipperscreen_WIFI
sudo ln -s ~/printer_data/config/config/scripts/klipperscreen/Klipperscreen_WIFI.sh /usr/local/bin/Klipperscreen_WIFI
sudo rm /usr/local/bin/Klipperscreen_STOP
sudo ln -s ~/printer_data/config/config/scripts/klipperscreen/Klipperscreen_STOP.sh /usr/local/bin/Klipperscreen_STOP

echo Creating LOGS scripts
sudo rm /usr/local/bin/LOGS_KLIPPER_CLEAN
sudo ln -s~/printer_data/config/config/scripts/logs/klipper/LOGS_KLIPPER_CLEAN.sh /usr/local/bin/LOGS_KLIPPER_CLEAN

echo Creating Obico scripts
sudo rm /usr/local/bin/Obico_START
sudo ln -s ~/printer_data/config/config/scripts/moonraker/obico/Obico_START.sh /usr/local/bin/Obico_START
sudo rm /usr/local/bin/Obico_STOP
sudo ln -s ~/printer_data/config/config/scripts/moonraker/obico/Obico_STOP.sh /usr/local/bin/Obico_STOP

echo Creating Octoeverywhere scripts
sudo rm /usr/local/bin/Octoeverywhere_START
sudo ln -s ~/printer_data/config/config/scripts/octoeverywhere/Octoeverywhere_START.sh /usr/local/bin/Octoeverywhere_START
sudo rm /usr/local/bin/Octoeverywhere_STOP
sudo ln -s ~/printer_data/config/config/scripts/octoeverywhere/Octoeverywhere_STOP.sh /usr/local/bin/Octoeverywhere_STOP

echo Creating Power Loss Recovery scripts
sudo rm /usr/local/bin/plr
sudo ln -s ~/printer_data/config/config/scripts/power-loss-recovery/plr.sh /usr/local/bin/plr
sudo rm /usr/local/bin/plr_z
sudo ln -s ~/printer_data/config/config/scripts/power-loss-recovery/plr_z.sh /usr/local/bin/plr_z

echo Creating timelapse clean scripts
sudo rm /usr/local/bin/timelapse_clean
sudo ln -s ~/printer_data/config/config/scripts/timelapse/timelapse_clean.sh /usr/local/bin/timelapse_clean

echo Creating USB scripts
sudo rm /usr/local/bin/USB_KEY
sudo ln -s ~/printer_data/config/config/scripts/usb/USB_KEY.sh /usr/local/bin/USB_KEY
sudo rm /usr/local/bin/USB_MOUNT
sudo ln -s ~/printer_data/config/config/scripts/usb/USB_MOUNT.sh /usr/local/bin/USB_MOUNT
sudo rm /usr/local/bin/USB_UNMOUNT
sudo ln -s ~/printer_data/config/config/scripts/usb/USB_UNMOUNT.sh /usr/local/bin/USB_UNMOUNT
sudo rm /usr/local/bin/USB_COPY
sudo ln -s ~/printer_data/config/config/scripts/usb/USB_COPY.sh /usr/local/bin/USB_COPY
sudo rm /usr/local/bin/USB_Check
sudo ln -s ~/printer_data/config/config/scripts/usb/USB_Check.sh /usr/local/bin/USB_Check

echo Creating WIFI scripts
sudo rm /usr/local/bin/Change_WIFI
sudo ln -s ~/printer_data/config/config/scripts/wifi/Change_WIFI.sh /usr/local/bin/Change_WIFI
sudo rm /usr/local/bin/Delete_WIFI
sudo ln -s ~/printer_data/config/config/scripts/wifi/Delete_WIFI.sh /usr/local/bin/Delete_WIFI
sudo rm /usr/local/bin/Show_WIFI
sudo ln -s ~/printer_data/config/config/scripts/wifi/Show_WIFI.sh /usr/local/bin/Show_WIFI


sudo find ~/printer_data/config/config/scripts/ -type f -name "*.sh" -exec chmod +x {} \;
