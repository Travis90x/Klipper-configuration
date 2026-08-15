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
passo 3, es. `PORT=7137 python3 app.py`.

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

```
pip install -r requirements.txt
python3 app.py
```

Apri `http://<ip-stampante>:7136/` nel browser.

Il servizio individua da solo `°ADV_macro.cfg` accanto a `app.py` (nella
directory superiore, `~/printer_data/config/`); se non lo trova usa
`advanced_macro.cfg`. Per puntare esplicitamente a un altro file:

```
KLIPPER_CONFIG_MANAGER_FILE=/percorso/a/°ADV_macro.cfg python3 app.py
```

## Sicurezza

Il servizio non ha autenticazione e può modificare la configurazione della
stampante: va esposto solo sulla rete locale fidata, non su internet.
