# Klipper Config Manager (WIP)

Local web service to toggle `[include ...]` lines in `°ADV_macro.cfg` from
the browser, grouped by section, instead of commenting/uncommenting lines
by hand.

Current status: include toggling only. Editing macro values (e.g.
coordinates) and conflict detection between alternative includes are not
implemented yet.

## Install & Run

After deploying the repo to `~/printer_data/config/` (see the main
`README.md`), `web/` sits directly inside `~/printer_data/config/`, next to
`advanced_macro.cfg` and `macro/` — **not** inside `macro/`.

```
cd ~/printer_data/config/web
```

### 1) Check port 7136 is free

```
if command -v ss >/dev/null 2>&1; then
    sudo ss -tulpn | grep ':7136 ' && echo ">>> PORT 7136 IN USE (see line above)" || echo ">>> Port 7136 free"
elif command -v lsof >/dev/null 2>&1; then
    sudo lsof -i :7136 && echo ">>> PORT 7136 IN USE (see above)" || echo ">>> Port 7136 free"
else
    echo ">>> Neither 'ss' nor 'lsof' installed: sudo apt install iproute2, then retry"
fi
```

If it's occupied, run on another port in step 3, e.g.
`PORT=7137 ~/klipper-config-manager-venv/bin/python3 app.py`.

### 2) Create °ADV_macro.cfg if missing

The service edits `°ADV_macro.cfg`, the copy actually included by the
printer (see the main `README.md`). Run from inside `web/`:

```
if [ -f ../°ADV_macro.cfg ]; then
    echo "°ADV_macro.cfg already exists, leaving it alone"
else
    cp ../advanced_macro.cfg ../°ADV_macro.cfg
    echo "Created °ADV_macro.cfg from advanced_macro.cfg"
fi
```

### 3) Install dependencies and run

Create the virtualenv outside `~/printer_data/config` (not inside `web/`),
e.g. in `~/klipper-config-manager-venv`:

```
python3 -m venv ~/klipper-config-manager-venv
~/klipper-config-manager-venv/bin/pip install -r requirements.txt
~/klipper-config-manager-venv/bin/python3 app.py
```

If `python3 -m venv` fails (e.g. "ensurepip is not available"):
```
sudo apt install -y python3-venv
```
then retry the command above.

Open `http://<printer-ip>:7136/` in your browser.

The service auto-detects `°ADV_macro.cfg` next to `app.py` (in the parent
directory, `~/printer_data/config/`); falls back to `advanced_macro.cfg` if
missing. To point at another file explicitly:

```
KLIPPER_CONFIG_MANAGER_FILE=/path/to/°ADV_macro.cfg ~/klipper-config-manager-venv/bin/python3 app.py
```

> Already have a venv inside `web/venv` (older guide)? Move it:
> ```
> sudo systemctl stop klipper_ai_macro.service 2>/dev/null
> rm -rf ~/printer_data/config/web/venv
> python3 -m venv ~/klipper-config-manager-venv
> ~/klipper-config-manager-venv/bin/pip install -r ~/printer_data/config/web/requirements.txt
> ```
> then redo step 4 to restart the service with the new path.

### 4) (Optional) Run in the background as a systemd service

Requires step 3 to have run at least once, so `~/klipper-config-manager-venv`
already exists:

```
sudo cp -r ~/printer_data/config/web/etc_systemd_system/* /etc/systemd/system/
sudo sed -i "s|/home/pi|$(eval echo ~$USER)|g" /etc/systemd/system/klipper_ai_macro.service
sudo systemctl daemon-reload
sudo systemctl enable --now klipper_ai_macro.service
```

Useful commands:

```
sudo systemctl status klipper_ai_macro.service   # status
journalctl -u klipper_ai_macro.service -f        # live logs
sudo systemctl restart klipper_ai_macro.service  # restart (e.g. after an update)
sudo systemctl stop klipper_ai_macro.service     # stop the service
sudo systemctl disable klipper_ai_macro.service  # don't start on boot anymore
```

## Update

After a manual update (`git pull` + `cp`, see the main README's Manual
Update), reinstall dependencies and restart the service:

```
~/klipper-config-manager-venv/bin/pip install -r ~/printer_data/config/web/requirements.txt
sudo systemctl restart klipper_ai_macro.service
```

Skip this if you update via the `UPDATE_KLIPPER_CONF` macro or Moonraker's
Update Manager — both already do it automatically.

## Security

No authentication; it can modify the printer's configuration — expose it
only on the trusted local network, never on the internet.
