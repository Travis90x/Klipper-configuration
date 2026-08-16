# Klipper-configuration

Enhance your Klipper

If Klipper does not update information

press CTRL+F5 to clean the cache of the browser.

# Backup
```
mkdir -p ~/printer_data/config/backup

if [ -d ~/printer_data/config ]; then
    BACKUP_DIR=~/printer_data/config/backup/config_$(date +%Y%m%d_%H%M%S)
    mkdir -p "$BACKUP_DIR"
    rsync -a --exclude='backup/' ~/printer_data/config/ "$BACKUP_DIR/"
    echo "Backup of ~/printer_data/config created in $BACKUP_DIR"
else
    echo "No existing ~/printer_data/config, skipping backup"
fi
```

The backup lives inside `~/printer_data/config/backup/`, not inside the repo
clone, so it can never end up committed to the public repo. Each backup is a
timestamped copy (`rsync -a --exclude='backup/' ...` excludes the `backup/`
folder itself, so it doesn't nest into itself on later runs). Old backups
are never overwritten — delete them by hand when you no longer need them.

Run this before **Download & Install** and before every **Manual Update**.

# Download & Install
```
cd
git clone -b Klipper_AI_macro https://github.com/Travis90x/Klipper-configuration.git ~/Klipper_AI_Macro

cp -r ~/Klipper_AI_Macro/* ~/printer_data/config/

for pair in "advanced_macro.cfg:°ADV_macro.cfg" "START.cfg:°START.cfg" "Accelerometer.cfg:°Accelerometer.cfg"; do
    src="${pair%%:*}"
    dst="${pair##*:}"
    if [ ! -f ~/printer_data/config/"$dst" ]; then
        cp ~/printer_data/config/"$src" ~/printer_data/config/"$dst"
        echo "Created $dst from $src"
    fi
done

sudo chown -R $USER: ~/printer_data
sudo find ~/printer_data/config/macro/scripts/ -type f -name "*.sh" -exec chmod +x {} \;
bash ~/printer_data/config/macro/scripts/update/klipper-configuration/klipper-configuration.sh
```

# Manual Update
```
cd
cd ~/Klipper_AI_Macro && git pull --rebase && cd -

cp -r ~/Klipper_AI_Macro/* ~/printer_data/config/

for pair in "advanced_macro.cfg:°ADV_macro.cfg" "START.cfg:°START.cfg" "Accelerometer.cfg:°Accelerometer.cfg"; do
    src="${pair%%:*}"
    dst="${pair##*:}"
    if [ ! -f ~/printer_data/config/"$dst" ]; then
        cp ~/printer_data/config/"$src" ~/printer_data/config/"$dst"
        echo "Created $dst from $src"
    fi
done

sudo chown -R $USER: ~/printer_data
sudo find ~/printer_data/config/macro/scripts/ -type f -name "*.sh" -exec chmod +x {} \;
bash ~/printer_data/config/macro/scripts/update/klipper-configuration/klipper-configuration.sh
```
or update using the Macro **UPDATE KLIPPER CONF** in Klipper or **UPDATE MANAGER** in Moonraker

# Printer.cfg

Rename **advanced_macro.cfg** in **°ADV_macro.cfg**, **START.cfg** in **°START.cfg**
and **Accelerometer.cfg** in **°Accelerometer.cfg**, then in your **printer.cfg** add
```
[include °ADV_macro.cfg]
[include °START.cfg]
```

`advanced_macro.cfg`, `START.cfg` and `Accelerometer.cfg` are reserve files kept in the
repo as version-tracked defaults. The `°`-prefixed copies are the ones actually loaded
by the printer and are meant to be customized by the user: edit them freely, an update
will never touch or overwrite them.

# Moonraker.conf

add this in moonraker.conf to update klipper-configuration 

```
[update_manager klipper-configuration]
type: git_repo
primary_branch: Klipper_AI_macro
path: ~/Klipper_AI_Macro
origin: https://github.com/Travis90x/Klipper-configuration.git
install_script: macro/scripts/update/klipper-configuration/klipper-configuration.sh # Deprecated by Moonraker
# Manual Update with putty:
# cp -r ~/Klipper_AI_Macro/* ~/printer_data/config
managed_services: klipper moonraker klipper_ai_macro
```
After updating from "Update Manager", use the Macro **UPDATE KLIPPER CONF** in Klipper
or 
```
sudo ~/printer_data/config/macro/scripts/update/klipper-configuration/klipper-configuration.sh
```

`klipper_ai_macro` in `managed_services` restarts the [Config Manager](web/README.md)
(`klipper_ai_macro.service`) after every update. Only takes effect if you've
already installed it as a systemd service (see the **WEB AI MACRO** section
below); otherwise Moonraker still tries to restart it and fails without
blocking the rest of the update.

# WEB AI MACRO

Config Manager: a small web UI to toggle `[include ...]` lines in
`°ADV_macro.cfg` from the browser, grouped by section (Mainsail, Macros,
KAMP, Fans, Probe, MCU, Input Shaping, Filament, Cutter, LED, Neopixel, MKS
Robin Nano...), instead of commenting/uncommenting lines by hand.

Full install, run and update guide: [web/README.md](web/README.md)

# CPU LOG
```
sudo cp -r ~/printer_data/config/macro/scripts/cpu/etc_systemd_system/* /etc/systemd/system/
sudo sed -i "s|/home/pi|$(eval echo ~$USER)|g" /etc/systemd/system/log_cpu.service
sed -i 's|/home/pi|'"$HOME"'|g' ~/printer_data/config/macro/scripts/cpu/LOG_CPU.sh
sudo systemctl daemon-reload
sudo systemctl enable log_cpu.timer
sudo systemctl enable log_cpu.service
sudo systemctl start log_cpu.timer
```
#### Example .../macro/scripts/logs/CPU/CPU.txt
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

Go to settings, General, Mainsail Settings in Moonraker DB, Restore, select **z_backup_mainsail_macro.json**, select Macro and Restore.

<img width="1920" alt="AI Macro" src="https://github.com/user-attachments/assets/5e93e97d-bbc8-4f36-9984-5447a2af6752" />

## Dashboard and Alexa automation here:
Reload WEB AI MACRO service
<img width="185" alt="AI_Macro_2" src="https://github.com/user-attachments/assets/3e183d0b-959e-45a2-acc7-022c1c5acbe3" />

## WEB AI MACRO

<img width="955" alt="AI_Macro_3" src="https://github.com/user-attachments/assets/55b5d3af-dcbd-4581-a131-a58950cefb14" />



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


<img src="https://onedrive.live.com/embed?resid=2A6BE858ABEEB97B%21716435&authkey=%21ADfZeGVQbG5wfy4&width=474&height=768" width="474" height="768" />

<img src="https://onedrive.live.com/embed?resid=2A6BE858ABEEB97B%21716431&authkey=%21AJcQ5X8GQ06RAag&width=473&height=547" width="473" height="547" />

<img src="https://onedrive.live.com/embed?resid=2A6BE858ABEEB97B%21716438&authkey=%21AIAnR-RZLMIS-SY&width=653&height=879" width="653" height="879" />


#  Schedule a print or job queue with Home Assistant automation

#### Add this dashboard
https://github.com/Travis90x/Klipper-configuration/blob/main/config/home_assistant/dashboard_start_print.yaml


<img src="https://onedrive.live.com/embed?resid=2A6BE858ABEEB97B%21716451&authkey=%21AJHak2fAaqFmY-U&width=398&height=110" width="398" height="110" />

Add in Home assistant configuration.yaml the code in the link below with your Moonraker printer IP, then restart HA.
#### https://github.com/Travis90x/Klipper-configuration/blob/main/config/home_assistant/configuration_start_print.yaml

#### Create an automation by customizing the code in the link below.
### Clean queue, start print file.gcode, add to queue 1.gcode, 2.gcode, print the queue
#### Customize these functions and schedule them as you need.
#### https://github.com/Travis90x/Klipper-configuration/blob/main/config/home_assistant/automation_start_print.yaml


