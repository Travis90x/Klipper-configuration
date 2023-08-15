# Klipper-configuration

Enhance your Klipper

# Donwload

git clone https://github.com/Travis90x/Klipper-configuration.git

Or update

cd ~/Klipper-configuration && git pull && cd -

# Install

sudo chown -R pi: ~/printer_data

cp -r ~/Klipper-configuration/* ~/printer_data/config

sudo find ~/printer_data/config/config/scripts/ -type f -name "*.sh" -exec chmod +x {} \;



# Printer.cfg

Copy the rows you need from printer.example.cfg

in your printer.cfg

# CPU LOG

sudo cp -r ~/printer_data/config/config/scripts/cpu/etc_systemd_system/* /etc/systemd/system/

sudo systemctl daemon-reload 

sudo systemctl enable log_cpu.timer

sudo systemctl start log_cpu.timer


#  USB

Automount and copy USB-KEY/gcodes in /home/pi/printer_data/gcodes

sudo apt install udisks2
