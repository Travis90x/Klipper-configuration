# Klipper-configuration — note per Claude

Raccolta di macro e sezioni Klipper riusabili, pensata per essere copiata dentro
`~/printer_data/config/` e richiamata dal `printer.cfg` dell'utente.
Non è la configurazione di una singola stampante: è una libreria.

## Come viene usata

Il repo si clona in `~/Klipper-configuration` (o in una cartella con altro
nome, es. `~/Klipper_AI_Macro` sul branch di test) e il contenuto si copia in
`~/printer_data/config/`. L'aggiornamento avviene via `update_manager` di
Moonraker o con la macro `UPDATE_KLIPPER_CONF`.

`~/printer_data/config/` è la cartella che usa Klipper/Moonraker: contiene
`printer.cfg`, `moonraker.conf`, `mainsail.conf` e tutti i file dell'utente,
non solo quelli di questo repo. Il comando di installazione è:

```
cp -r ~/Klipper_AI_Macro/* ~/printer_data/config/
```

Questo copia **ogni elemento di primo livello del repo** direttamente dentro
`~/printer_data/config/`, come fratelli diretti dei file di Klipper già
presenti lì (`printer.cfg`, `moonraker.conf`, ...):

```
~/printer_data/config/            <- cartella di Klipper/Moonraker
├── printer.cfg                   <- non di questo repo
├── moonraker.conf                <- non di questo repo
├── advanced_macro.cfg            <- repo, primo livello
├── °ADV_macro.cfg                <- copia rinominata di advanced_macro.cfg
├── web/                          <- repo, primo livello (tool config manager)
└── macro/                        <- repo, primo livello
    ├── macros/
    ├── sensors/
    └── scripts/
```

Nessuna cartella raddoppia: il repo ha una sua sottocartella chiamata
`macro/` (con dentro `macros/`, `sensors/`, `scripts/`, ecc.), nome scelto
apposta per non collidere con `config/` — la cartella di Klipper stessa. È
per questo che tutti gli `[include macro/macros/...]` in `advanced_macro.cfg`
risolvono correttamente: sono relativi a `~/printer_data/config/`.

> `macro/` è l'unico nome valido per questa sottocartella. Il vecchio schema
> `config/` (che produceva `~/printer_data/config/config/`) è stato abbandonato
> e non va più supportato: se trovi riferimenti a `config/config/` o a
> `[include config/...]`, sono errori da correggere, non stati legacy da
> preservare. Nessuno script deve contenere logica di migrazione dal vecchio
> schema.

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
di `[include ...]` verso `macro/`, con blocchi ASCII-art come separatori.
I file inclusi sono di due tipi:

- **macro** (`macro/macros/`, `macro/scripts/`, `macro/kamp/`)
- **sezioni Klipper** che abilitano hardware — sensori, accelerometri, ventole,
  neopixel, probe, driver TMC (`macro/accelerometer/`, `macro/sensors/`,
  `macro/fans/`, `macro/neopixel/`, ...)

La maggior parte degli `[include]` è **commentata di proposito**: l'utente
scommenta solo ciò che gli serve. Una riga commentata non è un errore.

## `macro/PRINTER_&_START_CONFIG_examples/`

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

Il meccanismo di scelta più comune non è commentare singole righe dentro una
sezione, ma commentare/decommentare interi `[include ...]` verso file diversi,
es.:

```
[include macro/.../tmc_motor_uart.cfg]
#[include macro/.../tmc_motor_spi.cfg]
```

per passare da SPI a UART. Quando invece la stessa sezione (es.
`[tmc2209 extruder]`) compare due volte nello **stesso** file con opzioni
diverse (`stealthchop_threshold` in un blocco, `uart_pin` nell'altro), Klipper
non dà errore: la parsa con `configparser.RawConfigParser(strict=False, ...)`,
che **accoda/unisce** le opzioni delle due occorrenze nella stessa sezione
finale. Questo è il pattern voluto e va lasciato com'è.

**Diverso invece è il caso di un `[include ...]` con lo stesso identico target,
ripetuto due volte nello stesso file, entrambe le righe attive (non
commentate).** Non è una scelta tra alternative (non ci sono due file diversi
tra cui scegliere): è la stessa identica inclusione duplicata per errore di
copia-incolla. Questo va corretto rimuovendo la ripetizione, come già fatto per
`Vivedino_Troodon_V2_adv_macro.cfg` (includeva due volte, entrambe attive,
`macro/scripts/input-shaping/input-shaping.cfg` e `shaper-graphs.cfg`).

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
