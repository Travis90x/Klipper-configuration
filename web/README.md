# Klipper Config Manager

Local web service to toggle `[include ...]` lines in `°ADV_macro.cfg` from
the browser, grouped by section, instead of commenting/uncommenting lines
by hand.

`web/` sits directly inside `~/printer_data/config/`, next to
`advanced_macro.cfg` and `macro/` — **not** inside `macro/`.

## Install (first time)

Runs as a systemd service by default, so it starts on boot and survives
reboots without needing a terminal open.

```
cd ~/printer_data/config/web

python3 -m venv ~/klipper-config-manager-venv
~/klipper-config-manager-venv/bin/pip install -r requirements.txt

sudo cp -r etc_systemd_system/* /etc/systemd/system/
sudo sed -i "s|/home/pi|$(eval echo ~$USER)|g" /etc/systemd/system/klipper_ai_macro.service
sudo systemctl daemon-reload
sudo systemctl enable --now klipper_ai_macro.service
```

If `python3 -m venv` fails (e.g. "ensurepip is not available"):
```
sudo apt install -y python3-venv
```
then retry the block above.

Open `http://<printer-ip>:7136/` in your browser.

The venv lives outside `~/printer_data/config` (in `~/klipper-config-manager-venv`)
so it isn't touched by updates, which only copy repo files into
`~/printer_data/config/`.

### Port 7136 already in use?

Check:
```
if command -v ss >/dev/null 2>&1; then
    sudo ss -tulpn | grep ':7136 ' && echo ">>> PORT 7136 IN USE (see line above)" || echo ">>> Port 7136 free"
elif command -v lsof >/dev/null 2>&1; then
    sudo lsof -i :7136 && echo ">>> PORT 7136 IN USE (see above)" || echo ">>> Port 7136 free"
else
    echo ">>> Neither 'ss' nor 'lsof' installed: sudo apt install iproute2, then retry"
fi
```

If it's busy, set a different port permanently in the service unit (replace
`7137` with whichever port you want):
```
sudo sed -i '/^\[Service\]/a Environment=PORT=7137' /etc/systemd/system/klipper_ai_macro.service
sudo systemctl daemon-reload
sudo systemctl restart klipper_ai_macro.service
```

## Update (e.g. after a manual `git pull --rebase`)

```
~/klipper-config-manager-venv/bin/pip install -r ~/printer_data/config/web/requirements.txt
sudo systemctl restart klipper_ai_macro.service
```

Skip this if you update via the `UPDATE_KLIPPER_CONF` macro or Moonraker's
Update Manager — both already do it automatically (see `managed_services` in
the main README's Moonraker.conf section).

## Useful commands

```
sudo systemctl status klipper_ai_macro.service   # status
journalctl -u klipper_ai_macro.service -f        # live logs
sudo systemctl restart klipper_ai_macro.service  # restart (e.g. after an update)
sudo systemctl stop klipper_ai_macro.service     # stop the service
sudo systemctl disable klipper_ai_macro.service  # don't start on boot anymore
```

Once `managed_services: klipper moonraker klipper_ai_macro` is set in
`moonraker.conf` (see the main README), `klipper_ai_macro.service` can also
be restarted from Mainsail/Fluidd the same way you restart the Klipper
service — no SSH needed.

## Editing a different file

The service auto-detects `°ADV_macro.cfg` next to `app.py` (in the parent
directory, `~/printer_data/config/`); falls back to `advanced_macro.cfg` if
missing. To point at another file explicitly:

```
KLIPPER_CONFIG_MANAGER_FILE=/path/to/°ADV_macro.cfg ~/klipper-config-manager-venv/bin/python3 app.py
```
