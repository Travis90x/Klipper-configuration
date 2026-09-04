# Migrazione da Cinemaniac a Trakt

Questo progetto fornisce uno script automatico per migrare la tua raccolta personale di film da Cinemaniac a Trakt.

## Panoramica

**Cinemaniac** è un'applicazione per gestire e valutare la tua raccolta di film. **Trakt** è un servizio online per tracciare film e serie TV.

Questo script converte i dati dal backup di Cinemaniac nel formato JSON compatibile con Trakt, permettendoti di:
- Trasferire i tuoi film visti da Cinemaniac a Trakt
- Migrare le valutazioni personali
- Mantenere la cronologia completa della tua raccolta

## Cosa Fa lo Script

Lo script `cinemaniac_to_trakt_migration.py` esegue le seguenti operazioni:

1. **Legge** il file di backup di Cinemaniac (`Cinemaniac.bak`)
2. **Converte** i film nel formato JSON di Trakt
3. **Genera** due file JSON:
   - `watched-movies.json`: Tutti i film della tua raccolta
   - `ratings-movies.json`: Film con le relative valutazioni personali
4. **Crea** un report di migrazione con statistiche

## Struttura dei Dati

### Input: Cinemaniac Backup

```json
{
  "movies": [
    {
      "id_movie": 5689,
      "title": "Laguna blu",
      "year": 331603200000,
      "rating": 6.138,
      "duration": 104,
      "genres": "12,18,10749",
      "overview": "...",
      "date": 1652306243090,
      "seen": 0,
      "note": "..."
    }
  ]
}
```

### Output: Formato Trakt

#### watched-movies.json
```json
[
  {
    "last_updated_at": "2026-09-04T01:55:07.982354Z",
    "last_watched_at": "2026-09-04T01:55:07.982354Z",
    "movie": {
      "ids": {
        "trakt": 5689,
        "slug": "laguna-blu",
        "tmdb": 5689,
        "imdb": "tt0005689"
      },
      "year": 1980,
      "title": "Laguna blu"
    },
    "plays": 1,
    "total_count": 1
  }
]
```

#### ratings-movies.json
```json
[
  {
    "rated_at": "2026-09-04T01:55:07.982354Z",
    "rating": 6,
    "type": "movie",
    "movie": { ... }
  }
]
```

## Utilizzo

### Requisiti
- Python 3.7+
- File di backup di Cinemaniac
- Accesso alle esportazioni di Trakt (opzionale, per confronti)

### Esecuzione

```bash
python3 cinemaniac_to_trakt_migration.py <percorso-cinemaniac.bak> <percorso-trakt-export> <directory-output>
```

**Esempio:**
```bash
python3 cinemaniac_to_trakt_migration.py Cinemaniac.bak ./trakt_export ./trakt_output
```

### Output

Lo script genera i seguenti file:

1. **watched-movies.json** - Tutti i film della tua raccolta in formato Trakt
2. **ratings-movies.json** - Film con valutazioni personali
3. **migration-report.json** - Report dettagliato della migrazione

## Statistiche di Migrazione

Il report include:

- **Total Movies**: Numero totale di film migrati
- **Watched Movies**: Film aggiunti alla lista dei visti
- **Rated Movies**: Film con valutazioni personali
- **Average Rating**: Valutazione media della raccolta
- **Migration Date**: Data e ora della migrazione

### Esempio Output

```
============================================================
REPORT DI MIGRAZIONE
============================================================
Data: 2026-09-04T01:55:07.982354
Fonte: Cinemaniac
Destinazione: Trakt

Film totali: 472
Film visti: 472
Film con valutazione: 472
Film senza valutazione: 0
Valutazione media: 6.62/10
============================================================
```

## Mappatura delle Valutazioni

Le valutazioni di Cinemaniac vengono convertite come segue:

| Cinemaniac | Trakt |
|-----------|-------|
| 0-10 | 1-10 |
| Nessuna valutazione | Non incluso in ratings-movies.json |

## Note Importanti

### ID dei Film
Gli ID dei film generati sono mappati come segue:
- **Trakt ID**: Usa l'ID di Cinemaniac come ID temporaneo
- **TMDB ID**: Copia dell'ID di Cinemaniac
- **IMDb ID**: Generato dal formato `tt{id:07d}`
- **Slug**: Versione URL-safe del titolo

**⚠️ IMPORTANTE**: Per una migrazione completa e accurata a Trakt, è consigliabile:
1. Utilizzare l'API di Trakt per cercare i film per titolo e anno
2. Mappare gli ID corretti (IMDb, TMDb, Trakt)
3. Verificare e correggere gli ID errati prima di importare

### Limitazioni Attuali

- Gli ID dei film sono mappati usando l'ID di Cinemaniac come ID temporaneo
- Per una migrazione completa, è consigliabile integrare l'API di Trakt per la ricerca accurata
- Le note e le categorie di Cinemaniac non sono attualmente incluse in Trakt

## Prossimi Passi

1. **Validazione**: Controlla il report di migrazione
2. **Backup**: Salva una copia del tuo backup di Cinemaniac
3. **Importazione**: Usa i file JSON generati per importare i dati in Trakt
4. **Verifica**: Controlla che i film siano stati importati correttamente

## Integrazione API Trakt (Opzionale)

Per una migrazione ancora più accurata, puoi integrare l'API di Trakt:

```python
import requests

def search_trakt_movie(title, year):
    url = f"https://api.trakt.tv/search/movie"
    params = {
        "query": title,
        "years": year
    }
    headers = {
        "trakt-api-version": "2",
        "trakt-api-key": "YOUR_API_KEY"
    }
    response = requests.get(url, params=params, headers=headers)
    return response.json()
```

Richiedi una Trakt API key su: https://trakt.tv/oauth/authorize/

## Supporto e Troubleshooting

### Il file Cinemaniac.bak non viene riconosciuto?
Assicurati che sia un file JSON valido:
```bash
python3 -m json.tool Cinemaniac.bak > /dev/null
```

### Errori nella conversione?
Controlla che:
- I film abbiano un ID valido (`id_movie`)
- Il titolo sia una stringa
- Le valutazioni siano numeri (0-10)

### Inconsistenze negli ID?
Questo è normale. Usa l'API di Trakt per mappare gli ID corretti tramite ricerca per titolo/anno.

## Licenza

Questo script è fornito come strumento per la migrazione dei dati personali.

## Contatti e Supporto

Per problemi o suggerimenti, contatta: travis90x@gmail.com

---

**Ultima modifica**: 2026-09-04
**Versione**: 1.0
