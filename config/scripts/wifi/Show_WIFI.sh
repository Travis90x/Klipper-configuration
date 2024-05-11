echo "$1" | sudo -S iwlist wlan0 scan > /dev/null
sudo iwlist wlan0 scan > /dev/null
nmcli dev wifi list
nmcli connection show | grep wifi
