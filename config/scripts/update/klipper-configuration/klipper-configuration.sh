git clone https://github.com/Travis90x/Klipper-configuration.git
cd ~/Klipper-configuration && git pull && cd -
sudo chown -R pi: ~/printer_data
cp -r ~/Klipper-configuration/* ~/printer_data/config
sfind ~/printer_data/config/config/scripts/ -type f -name "*.sh" -exec chmod +x {} ;
