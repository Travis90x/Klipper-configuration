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
    echo "Backup di ~/printer_data/config creato in $BACKUP_DIR"
else
    echo "Nessuna ~/printer_data/config esistente, backup saltato"
fi
```

Il backup vive dentro `~/printer_data/config/backup/`, non dentro il clone
del repo: non è quindi mai a rischio di finire committato nel repo pubblico.
Ogni backup è una copia con data/ora (`rsync -a --exclude='backup/' ...`
esclude la cartella `backup/` stessa dalla copia, così non si annida in se
stessa a ogni aggiornamento successivo). I backup vecchi non si
sovrascrivono — cancellali a mano quando non ti servono più.

Esegui questo comando prima di **Download & Install** e prima di ogni
**Manual Update**.

# Download & Install
```
cd
git clone -b Klipper_AI_macro https://github.com/Travis90x/Klipper-configuration.git ~/Klipper_AI_Macro

cp -r ~/Klipper_AI_Macro/* ~/printer_data/config/
sudo chown -R $USER: ~/printer_data
sudo find ~/printer_data/config/macro/scripts/ -type f -name "*.sh" -exec chmod +x {} \;
bash ~/printer_data/config/macro/scripts/update/klipper-configuration/klipper-configuration.sh
```

# Manual Update
```
cd
cd ~/Klipper_AI_Macro && git pull --rebase && cd -

cp -r ~/Klipper_AI_Macro/* ~/printer_data/config/
sudo chown -R $USER: ~/printer_data
sudo find ~/printer_data/config/macro/scripts/ -type f -name "*.sh" -exec chmod +x {} \;
bash ~/printer_data/config/macro/scripts/update/klipper-configuration/klipper-configuration.sh
```
or update using the Macro **UPDATE KLIPPER CONF** in Klipper or **UPDATE MANAGER** in Moonraker

# Printer.cfg

Rename **advanced_macro.cfg** in **°ADV_macro.cfg**
and in your **printer.cfg** add
```
[include °ADV_macro.cfg]
[include °START.cfg]
```

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
managed_services: klipper moonraker
```
After updating from "Update Manager", use the Macro **UPDATE KLIPPER CONF** in Klipper
or 
```
sudo ~/printer_data/config/macro/scripts/update/klipper-configuration/klipper-configuration.sh
```

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

Go to settings, General, Mainsail Settings in Moonraker DB, Restore, select **backup-mainsail_macro_"date".json**, select Macro and Restore.


![Macro Mainsail](https://github.com/Travis90x/Klipper-configuration/assets/23300077/66e5309e-1721-48f7-8b51-a8f002240f1e)

![immagine](https://github.com/user-attachments/assets/faada3aa-bd04-4590-98b6-edef149749bc)

![immagine](https://github.com/user-attachments/assets/9751a355-3d32-42e5-ae79-88493617cb12)

![immagine](https://github.com/user-attachments/assets/8952d387-5dfa-4cda-a72c-987623e9cc94)


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


