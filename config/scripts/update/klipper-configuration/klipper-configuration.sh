if [ ! -d ~/Klipper-configuration/ ]; then git clone https://github.com/Travis90x/Klipper-configuration.git ~/Klipper-configuration/; fi
cd ~/Klipper-configuration && git config pull.rebase true && cd -
cp -r ~/Klipper-configuration/* ~/printer_data/config
sudo chown -R $USER: ~/printer_data
sudo find ~/printer_data/config/config/scripts/ -type f -name "*.sh" -exec chmod +x {} \;
sudo rm /usr/local/bin/webcam_check
sudo ln -s ~/printer_data/config/config/scripts/webcam/webcam_check.sh /usr/local/bin/webcam_check
sudo rm /usr/local/bin/webcam_start
sudo ln -s ~/printer_data/config/config/scripts/webcam/webcam_start.sh /usr/local/bin/webcam_start
sudo rm /usr/local/bin/webcam_stop
sudo ln -s ~/printer_data/config/config/scripts/webcam/webcam_stop.sh  /usr/local/bin/webcam_stop
sudo rm /usr/local/bin/klipper-configuration-update
sudo ln -s ~/printer_data/config/config/scripts/update/klipper-configuration/klipper-configuration.sh /usr/local/bin/klipper-configuration-update
