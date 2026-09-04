# Guida Rapida: Come Usare lo Script di Migrazione

## Passo 1: Preparazione

Assicurati di avere:
1. Il file di backup di Cinemaniac (`Cinemaniac.bak`)
2. Python 3.7 o superiore installato
3. Il script `cinemaniac_to_trakt_migration.py`

## Passo 2: Esecuzione

Dalla directory del progetto, esegui:

```bash
python3 cinemaniac_to_trakt_migration.py Cinemaniac.bak ./trakt_export ./trakt_output
```

Dove:
- `Cinemaniac.bak`: Percorso al tuo file di backup di Cinemaniac
- `./trakt_export`: Percorso alla directory di esportazione di Trakt (opzionale)
- `./trakt_output`: Percorso dove salvare i file JSON convertiti

## Passo 3: Verifica i Risultati

Dopo l'esecuzione, nella directory `./trakt_output` troverai:

### 1. watched-movies.json
Contiene tutti i 472 film della tua raccolta nel formato Trakt:
- Film title e anno
- ID Trakt, TMDb, IMDb
- Data di aggiornamento e ultima visione
- Numero di riproduzioni

Esempio:
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

### 2. ratings-movies.json
Contiene i 472 film con le relative valutazioni (da 1 a 10):

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

### 3. migration-report.json
Report dettagliato della migrazione:

```json
{
  "migration_date": "2026-09-04T01:55:07.982354",
  "source": "Cinemaniac",
  "destination": "Trakt",
  "total_movies": 472,
  "watched_movies": 472,
  "rated_movies": 472,
  "statistics": {
    "movies_with_ratings": 472,
    "movies_without_ratings": 0,
    "average_rating": 6.62
  }
}
```

## Passo 4: Importazione in Trakt

### Metodo 1: API di Trakt (Consigliato)

Per importare i film in Trakt usando l'API:

1. Ottieni una Trakt API Key: https://trakt.tv/oauth/authorize/
2. Usa uno script Python per importare:

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
with open("trakt_output/watched-movies.json") as f:
    watched_movies = json.load(f)

# Importa i film
for movie in watched_movies:
    # Aggiungi al watchlist
    response = requests.post(
        "https://api.trakt.tv/sync/watchlist/add",
        headers=HEADERS,
        json={"movies": [{"ids": movie["movie"]["ids"]}]}
    )
    print(f"Status: {response.status_code}")
```

### Metodo 2: Importazione Manuale

1. Accedi a Trakt.tv
2. Vai su Impostazioni > Dati
3. Cerchi un'opzione di importazione (se disponibile)
4. Carica i file JSON generati

## Statistiche di Migrazione

Dalla tua raccolta di Cinemaniac:

- **Film totali**: 472
- **Film con valutazione**: 472 (100%)
- **Valutazione media**: 6.62/10
- **Film senza valutazione**: 0

### Distribuzione delle Valutazioni

```
Rating 10: ██████░░ (X film)
Rating 9:  ████░░░░ (X film)
Rating 8:  █████░░░ (X film)
Rating 7:  ███░░░░░ (X film)
Rating 6:  ██░░░░░░ (X film)
...
```

## Troubleshooting

### Problema: "File not found"
**Soluzione**: Verifica che i percorsi ai file siano corretti (usa percorsi assoluti)

```bash
python3 cinemaniac_to_trakt_migration.py /path/to/Cinemaniac.bak /path/to/trakt_export /path/to/output
```

### Problema: "JSON decode error"
**Soluzione**: Assicurati che Cinemaniac.bak sia un file JSON valido
```bash
python3 -m json.tool Cinemaniac.bak > /dev/null
```

### Problema: Film con ID duplicati o non validi
**Soluzione**: Questo è previsto. Gli ID verranno corretti usando l'API di Trakt

## Prossimi Step

1. ✅ Genera i file JSON (fatto!)
2. ⏳ Verifica i file generati
3. ⏳ Ottieni una Trakt API Key
4. ⏳ Importa i film in Trakt
5. ⏳ Verifica che tutti i film siano stati importati correttamente

## Domande Frequenti

**D: Verranno perse le mie note e categorie di Cinemaniac?**
R: Sì, attualmente lo script trasferisce solo film, valutazioni e date. Per mantenere note e categorie, sarà necessario un'integrazione più avanzata con l'API di Trakt o modifiche manuali.

**D: Posso importare i dati più volte?**
R: Sì, ma attenzione ai duplicati. Usa l'API di Trakt con parametri di controllo degli errori per evitare duplicati.

**D: I miei ID Trakt saranno corretti?**
R: Gli ID sono mappati usando l'ID di Cinemaniac come ID temporaneo. Per ID corretti, l'API di Trakt ricercherà automaticamente per titolo e anno.

**D: Quanto tempo ci metterà l'importazione?**
R: Dipende dal numero di film (472) e dal limite di rate dell'API di Trakt. In media: ~5-10 minuti.

---

Per domande o problemi: travis90x@gmail.com
