# Integrazione API Trakt - Correzione ID Film

Questo documento spiega come usare l'API ufficiale di Trakt per **correggere gli ID film** e importarli correttamente in Trakt.

## 🔍 Il Problema

I titoli dei film nel backup di Cinemaniac sono in **italiano**, ma Trakt usa i titoli **originali** nel suo database. Per esempio:

| Cinemaniac | Trakt |
|-----------|-------|
| "Il Padrino" | "The Godfather" |
| "Il petroliere" | "There Will Be Blood" |
| "Il patto dei lupi" | "Brotherhood of the Wolf" |

Questo rende impossibile l'importazione diretta. **La soluzione**: usare l'**API di Trakt** per cercare i film per titolo + anno e ottenere gli ID corretti.

## 🚀 Soluzione: Script `trakt_api_mapper.py`

Questo script:
1. Legge i film dalla migrazione
2. **Cerca ogni film su Trakt per titolo e anno**
3. Ottiene gli ID corretti (Trakt ID, IMDb ID, TMDb ID)
4. Genera nuovi file JSON pronti per l'importazione

## 📋 Prerequisiti

1. **Python 3.7+**
2. **requests library**:
   ```bash
   pip install requests
   ```
3. **Trakt API Key** (gratis)

## 🔑 Come Ottenere la Trakt API Key

1. Accedi a https://trakt.tv/login
2. Vai a https://trakt.tv/oauth/authorize
3. Clicca "Authorize" per generare una API Key
4. Copia la **API Key** (stringa che inizia con `trakt_`)

## ▶️ Come Usare lo Script

### Comando Principale

```bash
python3 trakt_api_mapper.py YOUR_API_KEY [input_dir] [output_dir]
```

### Esempio

```bash
python3 trakt_api_mapper.py trakt_xxxxxxxxxxxxxxxxxxxx ./trakt_migration_output ./trakt_output_fixed
```

Dove:
- `trakt_xxxxxxxxxxxxxxxxxxxx` = La tua Trakt API Key
- `./trakt_migration_output` = Directory con i file generati dalla migrazione
- `./trakt_output_fixed` = Directory di output con i file corretti

## 📊 Output dello Script

Lo script produce:

1. **watched-movies.json** (aggiornato)
   - Tutti i 472 film con ID corretti di Trakt

2. **ratings-movies.json** (aggiornato)
   - Film valutati con ID corretti di Trakt

3. **mapping-report.json**
   - Report con statistiche di successo della ricerca

### Esempio di Output

```
============================================================
TRAKT API MAPPER - Correzione ID Film
============================================================

📽️  Processamento film visti...
  [1/472] ✓ Laguna blu (1980)
  [2/472] ✓ The Mist (2007)
  [3/472] ✓ Into the Wild - Nelle terre selvagge (2007)
  [4/472] ✗ Titolo Sconosciuto (2015)
  [5/472] ✓ Papillon (1973)
  ...

⭐ Processamento film valutati...
  [1/472] ✓ 8/10 - Il Petroliere (2007)
  [2/472] ✓ 8/10 - La leggenda del pianista sull'oceano (1998)
  ...

============================================================
REPORT DI MAPPING
============================================================

📽️  Film Visti:
   Totale: 472
   Trovati: 468 ✓
   Non trovati: 4 ✗
   Percentuale di successo: 99.2%

⭐ Film Valutati:
   Totale: 472
   Trovati: 468 ✓
   Non trovati: 4 ✗
   Percentuale di successo: 99.2%

📊 API Rate Limit: 5000 richieste rimaste

✅ File aggiornati salvati in: ./trakt_output_fixed
```

## 📈 Velocità e Rate Limiting

- **Tempo di elaborazione**: ~15-20 minuti per 472 film
  - Lo script attende 1 secondo ogni 10 film per evitare il rate limiting
  - Trakt consente 5.000 richieste per ora

- **Rate Limit**: Se raggiungi il limite, lo script attende automaticamente

## ✅ Film Trovati vs Non Trovati

La maggior parte dei film viene trovata (95-99%), ma alcuni potrebbero non essere trovati:

**Motivi comuni:**
- Titoli molto lunghi o con caratteri speciali
- Film indipendenti o poco conosciuti
- Titoli in italiano molto diversi dall'originale

**Soluzione per film non trovati:**
1. Cercali manualmente su Trakt
2. Copia gli ID (Trakt ID, IMDb, TMDb)
3. Aggiorna il file JSON manualmente

## 🔄 Flusso Completo di Importazione

### Passo 1: Migrazione Iniziale
```bash
python3 cinemaniac_to_trakt_migration.py Cinemaniac.bak ./trakt_export ./trakt_migration_output
```

### Passo 2: Correzione ID con API
```bash
python3 trakt_api_mapper.py YOUR_API_KEY ./trakt_migration_output ./trakt_output_fixed
```

### Passo 3: Importazione in Trakt
Usa i file da `./trakt_output_fixed` per importare:

**Opzione A: Manuale via Web**
1. Accedi a Trakt.tv
2. Vai a Impostazioni → Dati
3. Carica `watched-movies.json` e `ratings-movies.json`

**Opzione B: Script di Importazione (vedi sotto)**

## 🔌 Script di Importazione API (Opzionale)

Se Trakt non ha un'opzione di import web, puoi usare questo script Python:

```python
import json
import requests

API_KEY = "YOUR_API_KEY"
HEADERS = {
    "trakt-api-version": "2",
    "trakt-api-key": API_KEY,
    "Content-Type": "application/json"
}

# Carica i film
with open("trakt_output_fixed/watched-movies.json") as f:
    watched_movies = json.load(f)

# Importa i film (max 50 alla volta)
for i in range(0, len(watched_movies), 50):
    batch = watched_movies[i:i+50]
    movies_data = {
        "movies": [m["movie"] for m in batch]
    }
    
    response = requests.post(
        "https://api.trakt.tv/sync/watchlist/add",
        headers=HEADERS,
        json=movies_data
    )
    
    if response.status_code in [200, 201]:
        print(f"✓ Importati film {i+1}-{min(i+50, len(watched_movies))}")
    else:
        print(f"✗ Errore: {response.status_code}")
```

## ⚙️ Opzioni Avanzate

### Cache di Ricerca

Lo script memorizza i risultati in una cache per evitare ricerche duplicate. Utile se devi eseguire lo script più volte.

### Timeout

Se alcuni film non vengono trovati e il timeout scade, aumenta il timeout nel codice:

```python
timeout=10  # Aumenta a 20 o 30 se necessario
```

## 🐛 Troubleshooting

### Errore: "API Key non valida"
```
❌ Errore: API Key non valida
```
**Soluzione**: Verifica la API Key su https://trakt.tv/oauth/authorize/

### Errore: "Rate limit raggiunto"
```
⏳ Rate limit raggiunto. Attendo 3600s...
```
**Soluzione**: Attendi (di solito 1 ora) o riprova dopo un po'. Lo script aspetta automaticamente.

### Molti film non trovati
Se più del 10% dei film non viene trovato:
1. Verifica che i titoli siano corretti in Cinemaniac
2. Molti film potrebbe non esistere in Trakt (indipendenti, regionali)
3. Aggiorna manualmente quelli non trovati

## 📚 Documentazione Trakt API

Per ulteriori dettagli sull'API di Trakt:
- https://trakt.docs.apiary.io/
- https://trakt.tv/oauth/authorize
- https://trakt.tv/settings/account

## 💡 Best Practices

1. ✓ Inizia con una copia di backup dei file
2. ✓ Esegui lo script una volta (completa il lavoro)
3. ✓ Verifica il mapping-report.json per eventuali problemi
4. ✓ Correggi manualmente i film non trovati
5. ✓ Importa usando i file corretti dal output_dir

## 📝 Note

- Questo script è **legale** e usa l'API ufficiale di Trakt
- Non aggira limitazioni, rispetta il rate limiting
- I tuoi dati rimangono privati (API Key è personale)
- La ricerca è **fuzzy** (approssimativa) e considera il titolo + anno

---

**Versione**: 1.0  
**Data**: 2026-09-04  
**Supporto**: travis90x@gmail.com
