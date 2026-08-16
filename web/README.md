# Klipper Config Manager (WIP)

Piccolo servizio web locale per attivare/disattivare gli `[include ...]` di
`°ADV_macro.cfg` con un toggle dal browser, invece di commentare/decommentare
le righe a mano.

Stato attuale: **solo attivazione/disattivazione degli include**. Editing dei
valori delle macro (es. coordinate) e rilevamento conflitti tra include
alternativi non sono ancora implementati.

## Installazione ed avvio

Dopo aver copiato il repo in `~/printer_data/config/` (vedi il `README.md`
principale), la cartella `web/` si trova direttamente dentro
`~/printer_data/config/`, allo stesso livello di `advanced_macro.cfg` e di
`macro/` — **non** dentro `macro/`.

```
cd ~/printer_data/config/web
```

### 1) Verifica che la porta 7136 sia libera

```
if command -v ss >/dev/null 2>&1; then
    sudo ss -tulpn | grep ':7136 ' && echo ">>> PORTA 7136 OCCUPATA (vedi riga sopra)" || echo ">>> Porta 7136 libera"
elif command -v lsof >/dev/null 2>&1; then
    sudo lsof -i :7136 && echo ">>> PORTA 7136 OCCUPATA (vedi sopra)" || echo ">>> Porta 7136 libera"
else
    echo ">>> Né 'ss' né 'lsof' installati: sudo apt install iproute2, poi riprova"
fi
```

Se stampa `PORTA 7136 OCCUPATA`, avvia il servizio su un'altra porta al
passo 3, es. `PORT=7137 venv/bin/python3 app.py`.

### 2) Verifica/crea °ADV_macro.cfg

Il servizio modifica `°ADV_macro.cfg`, la copia realmente inclusa dalla
stampante (vedi il `README.md` principale). Se non esiste ancora, va creata
copiando il master `advanced_macro.cfg`. Esegui i comandi da dentro `web/`
(come al passo precedente):

```
if [ -f ../°ADV_macro.cfg ]; then
    echo "°ADV_macro.cfg esiste già, non lo tocco"
else
    cp ../advanced_macro.cfg ../°ADV_macro.cfg
    echo "Creato °ADV_macro.cfg da advanced_macro.cfg"
fi
```

### 3) Installa le dipendenze e avvia

Su Raspberry Pi OS recenti (Bookworm e successivi) `pip install` di sistema è
bloccato di default ("externally-managed-environment") e può fallire in modo
poco chiaro. Per evitarlo, usa un virtualenv dedicato a questo tool — non
serve toccare il Python di sistema:

```
python3 -m venv venv
venv/bin/pip install -r requirements.txt
venv/bin/python3 app.py
```

Se `python3 -m venv` dà errore (es. "ensurepip is not available"):
```
sudo apt install -y python3-venv
```
poi riprova il comando sopra.

Apri `http://<ip-stampante>:7136/` nel browser.

Il servizio individua da solo `°ADV_macro.cfg` accanto a `app.py` (nella
directory superiore, `~/printer_data/config/`); se non lo trova usa
`advanced_macro.cfg`. Per puntare esplicitamente a un altro file:

```
KLIPPER_CONFIG_MANAGER_FILE=/percorso/a/°ADV_macro.cfg venv/bin/python3 app.py
```

### 4) (Opzionale) Avvialo in background come servizio systemd

Il comando `venv/bin/python3 app.py` del passo 3 resta legato al terminale:
se lo chiudi, il servizio si ferma. Per farlo girare in background, avviarsi
da solo al boot e riavviarsi da solo in caso di crash, installalo come
servizio systemd (richiede che il passo 3 sia già stato eseguito almeno una
volta, cioè che `web/venv` esista già):

```
sudo cp -r ~/printer_data/config/web/etc_systemd_system/* /etc/systemd/system/
sudo sed -i "s|/home/pi|$(eval echo ~$USER)|g" /etc/systemd/system/klipper-config-manager.service
sudo systemctl daemon-reload
sudo systemctl enable --now klipper-config-manager.service
```

Comandi utili:

```
sudo systemctl status klipper-config-manager.service   # stato
journalctl -u klipper-config-manager.service -f        # log in tempo reale
sudo systemctl restart klipper-config-manager.service  # riavvio (es. dopo un update)
sudo systemctl stop klipper-config-manager.service     # ferma il servizio
sudo systemctl disable klipper-config-manager.service  # non avviarlo più al boot
```

## Sicurezza

Il servizio non ha autenticazione e può modificare la configurazione della
stampante: va esposto solo sulla rete locale fidata, non su internet.
