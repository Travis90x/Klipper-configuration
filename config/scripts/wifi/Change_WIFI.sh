iwlist wlan0 scan
nmcli dev wifi list
nmcli dev wifi connect ${1} password ${2}
