# Klipper-configuration

Enhance your Klipper

If Klipper does not update information

press CTRL+F5 to clean the cache of the browser.

# Download & Install
```
git clone https://github.com/Travis90x/Klipper-configuration.git
mkdir -p ~/printer_data/config/ && cp -r ~/Klipper-configuration/* ~/printer_data/config/
sudo chown -R $USER: ~/printer_data
sudo find ~/printer_data/config/config/scripts/ -type f -name "*.sh" -exec chmod +x {} \;
```

# Update
```
cd ~/Klipper-configuration && git pull --rebase && cd -
mkdir -p ~/printer_data/config/ && cp -r ~/Klipper-configuration/* ~/printer_data/config/
sudo chown -R $USER: ~/printer_data
sudo find ~/printer_data/config/config/scripts/ -type f -name "*.sh" -exec chmod +x {} \;
```
or update using the Macro **UPDATE KLIPPER CONF** in Klipper

# Printer.cfg

Copy the rows you need from **advanced_macro.cfg** in your **printer.cfg**

Or rename **advanced_macro.cfg** in **macro.cfg** (because it will be overwritten by update process)
and in your **printer.cfg** add
```
[include macro.cfg]
```

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
After updating from "Update Manager", use the Macro **UPDATE KLIPPER CONF** in Klipper
or 
```
sudo ~/printer_data/config/config/scripts/update/klipper-configuration/klipper-configuration.sh
```

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











