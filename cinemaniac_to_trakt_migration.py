#!/usr/bin/env python3
"""
Migrazione da Cinemaniac a Trakt
Converte i film dalla raccolta personale di Cinemaniac al formato Trakt
"""

import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List


def load_cinemaniac_backup(filepath: str) -> Dict[str, Any]:
    """Carica il file di backup di Cinemaniac"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)


def load_trakt_export(filepath: str) -> Dict[str, Any]:
    """Carica l'esportazione di Trakt"""
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return data if isinstance(data, list) else {}


def create_movie_ids(cinemaniac_id: int, title: str, year: int) -> Dict[str, Any]:
    """
    Crea gli ID del film per Trakt.
    NOTA: Questi sono ID fittizi poiché non abbiamo mappature dirette.
    In un caso reale, useremmo l'API di Trakt per cercare i film per titolo/anno
    """
    return {
        "trakt": cinemaniac_id,  # Usiamo l'ID di Cinemaniac come ID Trakt temporaneo
        "slug": title.lower().replace(" ", "-").replace(":", "").replace("'", ""),
        "tmdb": cinemaniac_id,  # ID fittizio
        "imdb": f"tt{cinemaniac_id:07d}"  # ID fittizio
    }


def convert_cinemaniac_to_watched(cinemaniac_movie: Dict[str, Any]) -> Dict[str, Any]:
    """
    Converte un film di Cinemaniac al formato watched-movies di Trakt
    """
    # Converti il timestamp di year (in millisecondi) a anno
    year_ms = cinemaniac_movie.get('year', 0)
    year = int(year_ms / 1000 / 60 / 60 / 24 / 365.25 + 1970) if year_ms else 0

    movie = {
        "ids": create_movie_ids(
            cinemaniac_movie.get('id_movie', 0),
            cinemaniac_movie.get('title', 'Unknown'),
            year
        ),
        "year": year if year > 0 else None,
        "title": cinemaniac_movie.get('title', 'Unknown')
    }

    return {
        "last_updated_at": datetime.utcnow().isoformat() + ".000Z",
        "last_watched_at": datetime.utcnow().isoformat() + ".000Z",
        "movie": movie,
        "plays": 1,
        "total_count": 1
    }


def convert_cinemaniac_to_rating(cinemaniac_movie: Dict[str, Any]) -> Dict[str, Any] | None:
    """
    Converte un film di Cinemaniac al formato ratings-movies di Trakt
    Solo se ha una valutazione
    """
    rating = cinemaniac_movie.get('rating', 0)

    # Se non c'è valutazione, non includiamo il film
    if rating == 0:
        return None

    # Converti il timestamp di year (in millisecondi) a anno
    year_ms = cinemaniac_movie.get('year', 0)
    year = int(year_ms / 1000 / 60 / 60 / 24 / 365.25 + 1970) if year_ms else 0

    movie = {
        "ids": create_movie_ids(
            cinemaniac_movie.get('id_movie', 0),
            cinemaniac_movie.get('title', 'Unknown'),
            year
        ),
        "year": year if year > 0 else None,
        "title": cinemaniac_movie.get('title', 'Unknown')
    }

    # Converti la valutazione da scala Cinemaniac (0-10) a scala Trakt (1-10)
    trakt_rating = min(10, max(1, int(rating)))

    return {
        "rated_at": datetime.utcnow().isoformat() + ".000Z",
        "rating": trakt_rating,
        "type": "movie",
        "movie": movie
    }


def migrate_cinemaniac_to_trakt(
    cinemaniac_file: str,
    trakt_export_dir: str,
    output_dir: str
) -> None:
    """
    Esegue la migrazione da Cinemaniac a Trakt
    """
    print("Caricamento del backup di Cinemaniac...")
    cinemaniac_data = load_cinemaniac_backup(cinemaniac_file)

    movies = cinemaniac_data.get('movies', [])
    print(f"Trovati {len(movies)} film in Cinemaniac")

    # Converti i film al formato Trakt
    watched_movies = []
    rated_movies = []

    print("\nConversione dei film...")
    for movie in movies:
        # Aggiungi a watched-movies
        watched_entry = convert_cinemaniac_to_watched(movie)
        watched_movies.append(watched_entry)

        # Aggiungi a ratings-movies se ha una valutazione
        rating_entry = convert_cinemaniac_to_rating(movie)
        if rating_entry:
            rated_movies.append(rating_entry)

    # Crea la directory di output se non esiste
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    # Salva watched-movies.json
    watched_file = output_path / "watched-movies.json"
    with open(watched_file, 'w', encoding='utf-8') as f:
        json.dump(watched_movies, f, indent=2, ensure_ascii=False)
    print(f"\nSalvati {len(watched_movies)} film in {watched_file}")

    # Salva ratings-movies.json
    ratings_file = output_path / "ratings-movies.json"
    with open(ratings_file, 'w', encoding='utf-8') as f:
        json.dump(rated_movies, f, indent=2, ensure_ascii=False)
    print(f"Salvate {len(rated_movies)} valutazioni in {ratings_file}")

    # Salva un report di migrazione
    report = {
        "migration_date": datetime.utcnow().isoformat(),
        "source": "Cinemaniac",
        "destination": "Trakt",
        "total_movies": len(movies),
        "watched_movies": len(watched_movies),
        "rated_movies": len(rated_movies),
        "statistics": {
            "movies_with_ratings": len(rated_movies),
            "movies_without_ratings": len(watched_movies) - len(rated_movies),
            "average_rating": sum(m['rating'] for m in rated_movies) / len(rated_movies) if rated_movies else 0
        }
    }

    report_file = output_path / "migration-report.json"
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    print(f"\nReport di migrazione salvato in {report_file}")

    # Stampa il report
    print("\n" + "="*60)
    print("REPORT DI MIGRAZIONE")
    print("="*60)
    print(f"Data: {report['migration_date']}")
    print(f"Fonte: {report['source']}")
    print(f"Destinazione: {report['destination']}")
    print(f"\nFilm totali: {report['total_movies']}")
    print(f"Film visti: {report['watched_movies']}")
    print(f"Film con valutazione: {report['rated_movies']}")
    print(f"Film senza valutazione: {report['statistics']['movies_without_ratings']}")
    if report['rated_movies'] > 0:
        print(f"Valutazione media: {report['statistics']['average_rating']:.2f}/10")
    print("="*60)


def main():
    if len(sys.argv) != 4:
        print("Uso: python3 cinemaniac_to_trakt_migration.py <cinemaniac.bak> <trakt_export_dir> <output_dir>")
        print("\nEsempio:")
        print("  python3 cinemaniac_to_trakt_migration.py Cinemaniac.bak ./trakt_export ./trakt_output")
        sys.exit(1)

    cinemaniac_file = sys.argv[1]
    trakt_export_dir = sys.argv[2]
    output_dir = sys.argv[3]

    # Verifica che il file di Cinemaniac esista
    if not Path(cinemaniac_file).exists():
        print(f"Errore: File {cinemaniac_file} non trovato")
        sys.exit(1)

    try:
        migrate_cinemaniac_to_trakt(cinemaniac_file, trakt_export_dir, output_dir)
        print("\nMigrazione completata con successo!")
    except Exception as e:
        print(f"Errore durante la migrazione: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
