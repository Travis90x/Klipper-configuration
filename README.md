# Klipper-configuration

Enhance your Klipper

If Klipper does not update information

press CTRL+F5 to clean the cache of the browser.

# Download & Install
```
cd
git clone https://github.com/Travis90x/Klipper-configuration.git
mkdir -p ~/printer_data/config/ && cp -r ~/Klipper-configuration/* ~/printer_data/config/
sudo chown -R $USER: ~/printer_data
sudo find ~/printer_data/config/config/scripts/ -type f -name "*.sh" -exec chmod +x {} \;
```

# Update
```
cd
cd ~/Klipper-configuration && git pull --rebase && cd -
mkdir -p ~/printer_data/config/ && cp -r ~/Klipper-configuration/* ~/printer_data/config/
sudo chown -R $USER: ~/printer_data
sudo find ~/printer_data/config/config/scripts/ -type f -name "*.sh" -exec chmod +x {} \;
```
or update using the Macro **UPDATE KLIPPER CONF** in Klipper

# Printer.cfg

Copy the rows you need from **advanced_macro.cfg** in your **printer.cfg**

Or rename **advanced_macro.cfg** in **°ADV_macro.cfg** (because it will be overwritten by update process)
and in your **printer.cfg** add
```
[include °ADV_macro.cfg]
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
sudo systemctl start log_cpu.timer
```
#### Example .../config/scripts/logs/CPU/CPU.txt
##### https://www.site24x7.com/blog/load-average-what-is-it-and-whats-the-best-load-average-for-your-linux-servers
```
"load average: 0,46, 0,53, 0,46": 
average cpu load in last 1, 5 and 15 minutes 
1 = load on a core at 100%

7.1 2.8 /home/pi/klippy-env/bin/python
CPU at 7,1% at and RAM at 2,8%
```
#  USB

Automount and copy USB-KEY/gcodes in /home/YourUser/printer_data/gcodes
```
sudo apt install udisks2
```

# Mainsail Macro

## Restore Macro Buttons

Go to settings, General, Mainsail Settings in Moonraker DB, Restore, select **backup-mainsail_macro_"date".json**, select Macro and Restore.


![Macro Mainsail](https://github.com/Travis90x/Klipper-configuration/assets/23300077/66e5309e-1721-48f7-8b51-a8f002240f1e)



#  Home Assistant + Alexa

<img src="https://onedrive.live.com/embed?resid=2A6BE858ABEEB97B%21716441&authkey=%21ACP4y-KNnQguGmI&width=571&height=358" width="571" height="358" />

## Dashboard and Alexa automation here:

Install in HACS:
##### https://github.com/marcolivierarsenault/moonraker-home-assistant
##### https://github.com/kalkih/mini-graph-card
##### https://github.com/thomasloven/lovelace-card-mod
##### https://github.com/alandtse/alexa_media_player 

Dashboard Lovelace Source:

##### https://github.com/NonaSuomy/Moonraker-Home-Assistant?tab=readme-ov-file#lovelace-cards

## My custom dashboards and automations here:
##### https://github.com/Travis90x/Klipper-configuration/tree/main/config/home_assistant

### Automation: 
#### Alexa notify all Klipper messages with "M117 Alexa <message_to_notify>"
#### Alexa notify "The filament has run out
#### Clean queue, start print file.gcode, add to queue 1.gcode, 2.gcode, print the queue (customize these functions and schedule them).

<img src="https://onedrive.live.com/embed?resid=2A6BE858ABEEB97B%21716435&authkey=%21ADfZeGVQbG5wfy4&width=474&height=768" width="474" height="768" />

<img src="https://onedrive.live.com/embed?resid=2A6BE858ABEEB97B%21716431&authkey=%21AJcQ5X8GQ06RAag&width=473&height=547" width="473" height="547" />

<img src="https://onedrive.live.com/embed?resid=2A6BE858ABEEB97B%21716438&authkey=%21AIAnR-RZLMIS-SY&width=653&height=879" width="653" height="879" />


#  Schedule a print or job queue with Home Assistant automation

<img src="https://onedrive.live.com/embed?resid=2A6BE858ABEEB97B%21716451&authkey=%21AJHak2fAaqFmY-U&width=398&height=110" width="398" height="110" />

Add in Home assistant configuration.yaml the code in the link below with your Moonraker printer IP, then restart HA.
#### https://github.com/Travis90x/Klipper-configuration/blob/main/config/home_assistant/start_print_configuration.yaml

#### Create an automation by customizing the code in the link below.
#### https://github.com/Travis90x/Klipper-configuration/blob/main/config/home_assistant/start_print_automation.yaml

Add in the Dashboard, edit macro names:
#### https://github.com/Travis90x/Klipper-configuration/tree/main/config/home_assistant
