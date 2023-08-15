if [ ! -d ~/Klipper-configuration/ ]; then git clone https://github.com/Travis90x/Klipper-configuration.git ~/Klipper-configuration/; fi
cd ~/Klipper-configuration && git pull && cd -
cp -r ~/Klipper-configuration/* ~/printer_data/config
