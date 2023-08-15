git clone https://github.com/Travis90x/Klipper-configuration.git
echo Don't worry if already exists, it will be updated
cd ~/Klipper-configuration && git pull && cd -
cp -r ~/Klipper-configuration/* ~/printer_data/config
