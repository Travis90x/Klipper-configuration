# Klipper-configuration-
Enhance your Klipper

# PUTTY - Give execute permission for all scripts

#### sudo chown -R pi: /home/pi/printer_data
#### sfind ~/printer_data/config/config/scripts/ -type f -name "*.sh" -exec chmod +x {} \;



# CPU LOG
##### Copy the content of folder /config/script/cpu/etc_systemd_system/ in your /etc/systemd/system

### then with putty:

#### sudo systemctl daemon-reload 
#### sudo systemctl enable log_cpu.timer
#### sudo systemctl start log_cpu.timer


#  USB
## Automount and copy USB-KEY/gcodes in /home/pi/printer_data/gcodes

#### sudo apt install udisks2
