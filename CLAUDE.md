# Klipper-configuration — note per Claude

Raccolta di macro e sezioni Klipper riusabili, pensata per essere copiata dentro
`~/printer_data/config/` e richiamata dal `printer.cfg` dell'utente.
Non è la configurazione di una singola stampante: è una libreria.

## Come viene usata

Il repo si clona in `~/Klipper-configuration` e il contenuto si copia in
`~/printer_data/config/`. L'aggiornamento avviene via `update_manager` di
Moonraker o con la macro `UPDATE_KLIPPER_CONF`.

Nel `printer.cfg` l'utente include due soli file:

```
[include °ADV_macro.cfg]
[include °START.cfg]
```

Il prefisso `°` serve a far comparire questi file in cima all'elenco nell'editor
di Mainsail.

## Convenzione importante: i file `°`

| File nel repo | Copia in uso | Ruolo |
|---|---|---|
| `advanced_macro.cfg` | `°ADV_macro.cfg` | master versionato → copia attiva |
| `START.cfg` | `°START.cfg` | master versionato → copia attiva |

**`advanced_macro.cfg` e `START.cfg` sono i file di riferimento tenuti nel repo
come backup.** Le copie rinominate con `°` sono quelle realmente incluse dalla
stampante e possono divergere: sono personalizzate per la macchina specifica.

Di conseguenza:

- Non "correggere" i riferimenti a `°ADV_macro.cfg` / `°ADV_MACRO.cfg` /
  `°START.cfg` segnalandoli come include rotti: quei file non stanno nel repo,
  nascono dalla copia fatta dall'utente.
- Le differenze di maiuscole nei nomi `°ADV_*` vanno lasciate come sono.

## Struttura

`advanced_macro.cfg` è un indice: non contiene quasi logica, ma una lunga serie
di `[include ...]` verso `config/`, con blocchi ASCII-art come separatori.
I file inclusi sono di due tipi:

- **macro** (`config/macros/`, `config/scripts/`, `config/kamp/`)
- **sezioni Klipper** che abilitano hardware — sensori, accelerometri, ventole,
  neopixel, probe, driver TMC (`config/accelerometer/`, `config/sensors/`,
  `config/fans/`, `config/neopixel/`, ...)

La maggior parte degli `[include]` è **commentata di proposito**: l'utente
scommenta solo ciò che gli serve. Una riga commentata non è un errore.

## `config/PRINTER_&_START_CONFIG_examples/`

Cartella di **backup ed esempi**, non codice attivo. Contiene `printer.cfg`,
`°ADV_macro.cfg` e `°START.cfg` reali di stampanti diverse:

- Sapphire Plus SP5 (anche in variante Creality Sonic Pad)
- Sapphire Pro SP3
- VzBot 330 Mellow
- Vivedino Troodon V2
- Bambulab X1C (solo G-code di start per lo slicer)

Nessuno di questi file viene incluso dal repo. Servono come riferimento per chi
ha la stessa macchina. Trattali come archivio: correggi solo errori evidenti e
non uniformarli tra loro.

`PRESET_DEFAULT.cfg` e i file sotto `BAMBULAB/` sono **snippet di G-code per lo
slicer**, non config Klipper: è normale che non abbiano intestazioni di sezione.

## Sezioni duplicate: sono volute

In diversi file la stessa sezione compare due volte (`[duplicate_pin_override]`,
`[tmc2209 extruder]`, `[board_pins ...]`, alcune macro). **Sono alternative:**
l'utente ne attiva una e commenta l'altra. Non vanno unite né deduplicate.

## Se devi validare la sintassi

Klipper usa Jinja2 con delimitatori **non standard**: `{% %}` per i blocchi ma
**`{ }` (parentesi singole)** per le variabili, non `{{ }}`. Validare con i
delimitatori di default produce decine di falsi positivi.

```python
env = jinja2.Environment('{%', '%}', '{', '}', extensions=["jinja2.ext.do"])
```

Il parsing dei file replica `configparser.RawConfigParser(strict=False,
inline_comment_prefixes=(';', '#'))`.

## Sicurezza

Password, SSID e token non vanno mai scritti nei file: le macro li ricevono come
parametri a runtime (`params.PASSWORD`, `params.SSID`) con segnaposto nei
default. Il repo è pubblico — mantieni questa impostazione.
