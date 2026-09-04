#!/usr/bin/env python3
"""
Trakt API Mapper - Ricerca film per titolo e anno e ottiene ID corretti
Questo script corregge il mapping dei film usando l'API ufficiale di Trakt
"""

import json
import time
import sys
import os
from typing import Any, Dict, List, Optional
from pathlib import Path
from datetime import datetime

try:
    import requests
except ImportError:
    print("Errore: requests non è installato")
    print("Installa con: pip install requests")
    sys.exit(1)


class TraktAPIMapper:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.trakt.tv"
        self.headers = {
            "trakt-api-version": "2",
            "trakt-api-key": api_key,
            "Content-Type": "application/json"
        }
        self.cache = {}
        self.rate_limit_remaining = None
        self.rate_limit_reset = None

    def search_movie(self, title: str, year: Optional[int] = None) -> Optional[Dict[str, Any]]:
        """
        Cerca un film su Trakt per titolo e anno
        Ritorna il primo risultato (quello più rilevante)
        """
        # Controlla cache
        cache_key = f"{title}_{year}"
        if cache_key in self.cache:
            return self.cache[cache_key]

        try:
            params = {"query": title}
            if year:
                params["years"] = str(year)

            response = requests.get(
                f"{self.base_url}/search/movie",
                headers=self.headers,
                params=params,
                timeout=10
            )

            # Gestisci rate limiting
            if "X-RateLimit-Remaining" in response.headers:
                self.rate_limit_remaining = int(response.headers["X-RateLimit-Remaining"])
                self.rate_limit_reset = int(response.headers["X-RateLimit-Reset"])

            if response.status_code == 401:
                print(f"❌ Errore: API Key non valida")
                return None

            if response.status_code == 429:
                reset_time = int(response.headers.get("X-RateLimit-Reset", 0))
                wait_time = reset_time - int(time.time())
                print(f"⏳ Rate limit raggiunto. Attendo {wait_time}s...")
                time.sleep(wait_time + 1)
                return self.search_movie(title, year)

            if response.status_code != 200:
                print(f"⚠️  Errore nella ricerca di '{title}': {response.status_code}")
                return None

            results = response.json()
            if results and len(results) > 0:
                # Prendi il primo risultato (più rilevante)
                result = results[0]
                self.cache[cache_key] = result
                return result

            return None

        except requests.exceptions.Timeout:
            print(f"⚠️  Timeout nella ricerca di '{title}'")
            return None
        except Exception as e:
            print(f"⚠️  Errore nella ricerca di '{title}': {str(e)}")
            return None

    def update_movie_ids(self, movie: Dict[str, Any]) -> Dict[str, Any]:
        """
        Aggiorna gli ID di un film usando i dati di Trakt
        """
        title = movie.get("movie", {}).get("title", "")
        year = movie.get("movie", {}).get("year")

        if not title:
            return movie

        # Cerca il film su Trakt
        search_result = self.search_movie(title, year)

        if search_result and "movie" in search_result:
            trakt_movie = search_result["movie"]
            trakt_ids = trakt_movie.get("ids", {})

            # Aggiorna gli ID
            movie["movie"]["ids"] = {
                "trakt": trakt_ids.get("trakt", 0),
                "slug": trakt_ids.get("slug", ""),
                "tmdb": trakt_ids.get("tmdb", 0),
                "imdb": trakt_ids.get("imdb", "")
            }

            return movie, True
        else:
            return movie, False

    def show_rate_limit_status(self):
        """Mostra lo stato del rate limiting"""
        if self.rate_limit_remaining is not None:
            print(f"📊 API Rate Limit: {self.rate_limit_remaining} richieste rimaste")
            if self.rate_limit_remaining < 10:
                print("⚠️  Poche richieste rimaste!")


def process_watched_movies(api_mapper: TraktAPIMapper, input_file: str, output_file: str) -> Dict[str, int]:
    """
    Processa i film watched e aggiorna gli ID usando l'API di Trakt
    """
    print(f"\n📽️  Processamento film visti...")

    with open(input_file, 'r', encoding='utf-8') as f:
        movies = json.load(f)

    updated_movies = []
    stats = {"total": len(movies), "found": 0, "not_found": 0}

    for i, movie in enumerate(movies):
        title = movie.get("movie", {}).get("title", "")
        year = movie.get("movie", {}).get("year")

        updated_movie, found = api_mapper.update_movie_ids(movie)
        updated_movies.append(updated_movie)

        status = "✓" if found else "✗"
        print(f"  [{i+1}/{len(movies)}] {status} {title} ({year})")

        if found:
            stats["found"] += 1
        else:
            stats["not_found"] += 1

        # Evita rate limiting
        if (i + 1) % 10 == 0:
            api_mapper.show_rate_limit_status()
            time.sleep(1)

    # Salva i film aggiornati
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(updated_movies, f, indent=2, ensure_ascii=False)

    return stats


def process_rated_movies(api_mapper: TraktAPIMapper, input_file: str, output_file: str) -> Dict[str, int]:
    """
    Processa i film con valutazioni e aggiorna gli ID usando l'API di Trakt
    """
    print(f"\n⭐ Processamento film valutati...")

    with open(input_file, 'r', encoding='utf-8') as f:
        movies = json.load(f)

    updated_movies = []
    stats = {"total": len(movies), "found": 0, "not_found": 0}

    for i, movie in enumerate(movies):
        title = movie.get("movie", {}).get("title", "")
        year = movie.get("movie", {}).get("year")

        updated_movie, found = api_mapper.update_movie_ids(movie)
        updated_movies.append(updated_movie)

        rating = movie.get("rating", "?")
        status = "✓" if found else "✗"
        print(f"  [{i+1}/{len(movies)}] {status} {rating}/10 - {title} ({year})")

        if found:
            stats["found"] += 1
        else:
            stats["not_found"] += 1

        # Evita rate limiting
        if (i + 1) % 10 == 0:
            api_mapper.show_rate_limit_status()
            time.sleep(1)

    # Salva i film aggiornati
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(updated_movies, f, indent=2, ensure_ascii=False)

    return stats


def main():
    if len(sys.argv) < 2:
        print("Uso: python3 trakt_api_mapper.py <API_KEY> [input_dir] [output_dir]")
        print("\nEsempio:")
        print("  python3 trakt_api_mapper.py YOUR_API_KEY ./trakt_migration_output ./trakt_output_fixed")
        print("\nOttieni una API Key su: https://trakt.tv/oauth/authorize/")
        sys.exit(1)

    api_key = sys.argv[1]
    input_dir = sys.argv[2] if len(sys.argv) > 2 else "./trakt_migration_output"
    output_dir = sys.argv[3] if len(sys.argv) > 3 else "./trakt_output_fixed"

    # Verifica i file di input
    watched_file = Path(input_dir) / "watched-movies.json"
    rated_file = Path(input_dir) / "ratings-movies.json"

    if not watched_file.exists() or not rated_file.exists():
        print(f"❌ Errore: File di input non trovati in {input_dir}")
        sys.exit(1)

    # Crea la directory di output
    Path(output_dir).mkdir(parents=True, exist_ok=True)

    # Inizializza il mapper
    mapper = TraktAPIMapper(api_key)

    print("="*60)
    print("TRAKT API MAPPER - Correzione ID Film")
    print("="*60)

    # Processa i film visti
    watch_stats = process_watched_movies(
        mapper,
        str(watched_file),
        str(Path(output_dir) / "watched-movies.json")
    )

    # Processa i film valutati
    rating_stats = process_rated_movies(
        mapper,
        str(rated_file),
        str(Path(output_dir) / "ratings-movies.json")
    )

    # Report finale
    print("\n" + "="*60)
    print("REPORT DI MAPPING")
    print("="*60)
    print(f"\n📽️  Film Visti:")
    print(f"   Totale: {watch_stats['total']}")
    print(f"   Trovati: {watch_stats['found']} ✓")
    print(f"   Non trovati: {watch_stats['not_found']} ✗")
    print(f"   Percentuale di successo: {100*watch_stats['found']/watch_stats['total']:.1f}%")

    print(f"\n⭐ Film Valutati:")
    print(f"   Totale: {rating_stats['total']}")
    print(f"   Trovati: {rating_stats['found']} ✓")
    print(f"   Non trovati: {rating_stats['not_found']} ✗")
    print(f"   Percentuale di successo: {100*rating_stats['found']/rating_stats['total']:.1f}%")

    mapper.show_rate_limit_status()

    print(f"\n✅ File aggiornati salvati in: {output_dir}")
    print("="*60)

    # Salva un report di mapping
    report = {
        "mapping_date": datetime.utcnow().isoformat(),
        "api_provider": "Trakt",
        "watched_movies": watch_stats,
        "rated_movies": rating_stats,
        "success_rate": {
            "watched": f"{100*watch_stats['found']/watch_stats['total']:.1f}%",
            "rated": f"{100*rating_stats['found']/rating_stats['total']:.1f}%"
        }
    }

    report_file = Path(output_dir) / "mapping-report.json"
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)

    print(f"📊 Report salvato in: {report_file}")


if __name__ == "__main__":
    main()
