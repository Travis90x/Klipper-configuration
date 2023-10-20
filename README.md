# Klipper-configuration

Enhance your Klipper

If Klipper does not update information

press CTRL+F5 to clean the cache of the browser.

# Download & Install
```
git clone https://github.com/Travis90x/Klipper-configuration.git
sudo chown -R $USER: ~/printer_data
cp -r ~/Klipper-configuration/* ~/printer_data/config
sudo find ~/printer_data/config/config/scripts/ -type f -name "*.sh" -exec chmod +x {} \;
```

# Update
```
cd ~/Klipper-configuration && git pull && cd -
cp -r ~/Klipper-configuration/* ~/printer_data/config
sudo chown -R $USER: ~/printer_data
sudo find ~/printer_data/config/config/scripts/ -type f -name "*.sh" -exec chmod +x {} \;
```
or update using the Macro **UPDATE KLIPPER CONF** in Klipper

# Printer.cfg

Copy the rows you need from **advanced_macro.cfg** in your **printer.cfg**
Or in your **printer.cfg** add this
[include advanced_macro.cfg]

# Moonraker.conf

add this in moonraker.conf to update klipper-configuration 

```
[update_manager klipper-configuration]
type: git_repo
primary_branch: main
path: ~/Klipper-configuration
origin: https://github.com/Travis90x/Klipper-configuration.git
install_script: config/scripts/update/klipper-configuration/klipper-configuration.sh # Deprecated by Moonraker
# Manual Update with putty:
# cp -r ~/Klipper-configuration/* ~/printer_data/config
managed_services: klipper moonraker
```
After updating, re-execute Install commands because install_script is deprecated

# CPU LOG
```
sudo cp -r ~/printer_data/config/config/scripts/cpu/etc_systemd_system/* /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable log_cpu.timer
sudo systemctl start log_cpu.timer`
```

#  USB

Automount and copy USB-KEY/gcodes in /home/YourUser/printer_data/gcodes
```
sudo apt install udisks2
```











