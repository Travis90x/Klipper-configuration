# Klipper Config Manager (WIP)

Piccolo servizio web locale per attivare/disattivare gli `[include ...]` di
`°ADV_macro.cfg` (o `advanced_macro.cfg` in questo repo, per test) con un
toggle dal browser, invece di commentare/decommentare le righe a mano.

Stato attuale: **solo attivazione/disattivazione degli include**. Editing dei
valori delle macro (es. coordinate) e rilevamento conflitti tra include
alternativi non sono ancora implementati.

## Uso

```
cd config/scripts/config-manager
pip install -r requirements.txt
python3 app.py
```

Apri `http://<ip-stampante>:7136/` nel browser.

Di default il servizio modifica `°ADV_macro.cfg` nella root del repo/copia
locale, se presente, altrimenti `advanced_macro.cfg`. Per puntare esplicitamente
al file attivo sulla stampante:

```
KLIPPER_CONFIG_MANAGER_FILE=/home/pi/printer_data/config/°ADV_macro.cfg python3 app.py
```

## Sicurezza

Il servizio non ha autenticazione e può modificare la configurazione della
stampante: va esposto solo sulla rete locale fidata, non su internet.
