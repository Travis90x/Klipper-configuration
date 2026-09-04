#!/usr/bin/env python3
"""
Test dello script di migrazione da Cinemaniac a Trakt
Valida che i file generati siano nel formato corretto
"""

import json
import sys
from pathlib import Path
from typing import Any, Dict, List


def validate_watched_movies(filepath: str) -> tuple[bool, str]:
    """Valida la struttura di watched-movies.json"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        if not isinstance(data, list):
            return False, "watched-movies.json deve essere un array"

        if len(data) == 0:
            return False, "watched-movies.json è vuoto"

        # Valida il primo film
        first_movie = data[0]
        required_fields = ['last_updated_at', 'last_watched_at', 'movie', 'plays', 'total_count']

        for field in required_fields:
            if field not in first_movie:
                return False, f"Campo mancante '{field}' nel primo film"

        # Valida la struttura del film
        movie = first_movie['movie']
        movie_required = ['ids', 'title', 'year']

        for field in movie_required:
            if field not in movie:
                return False, f"Campo mancante '{field}' nella struttura del film"

        # Valida gli IDs
        ids = movie['ids']
        ids_required = ['trakt', 'slug', 'tmdb', 'imdb']

        for field in ids_required:
            if field not in ids:
                return False, f"ID mancante '{field}' nella struttura"

        return True, f"✓ watched-movies.json valido ({len(data)} film)"

    except json.JSONDecodeError as e:
        return False, f"Errore JSON: {str(e)}"
    except Exception as e:
        return False, f"Errore nella validazione: {str(e)}"


def validate_ratings_movies(filepath: str) -> tuple[bool, str]:
    """Valida la struttura di ratings-movies.json"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        if not isinstance(data, list):
            return False, "ratings-movies.json deve essere un array"

        if len(data) == 0:
            return True, "✓ ratings-movies.json vuoto (nessuna valutazione)"

        # Valida il primo film valutato
        first_rating = data[0]
        required_fields = ['rated_at', 'rating', 'type', 'movie']

        for field in required_fields:
            if field not in first_rating:
                return False, f"Campo mancante '{field}' nel primo film valutato"

        # Valida la valutazione
        rating = first_rating['rating']
        if not isinstance(rating, int) or rating < 1 or rating > 10:
            return False, f"Valutazione non valida: {rating} (deve essere 1-10)"

        if first_rating['type'] != 'movie':
            return False, f"Tipo non valido: {first_rating['type']} (deve essere 'movie')"

        return True, f"✓ ratings-movies.json valido ({len(data)} film valutati)"

    except json.JSONDecodeError as e:
        return False, f"Errore JSON: {str(e)}"
    except Exception as e:
        return False, f"Errore nella validazione: {str(e)}"


def validate_migration_report(filepath: str) -> tuple[bool, str]:
    """Valida il report di migrazione"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        required_fields = [
            'migration_date', 'source', 'destination',
            'total_movies', 'watched_movies', 'rated_movies',
            'statistics'
        ]

        for field in required_fields:
            if field not in data:
                return False, f"Campo mancante '{field}' nel report"

        stats_fields = [
            'movies_with_ratings',
            'movies_without_ratings',
            'average_rating'
        ]

        for field in stats_fields:
            if field not in data['statistics']:
                return False, f"Campo statistico mancante '{field}'"

        return True, f"✓ Report di migrazione valido"

    except json.JSONDecodeError as e:
        return False, f"Errore JSON: {str(e)}"
    except Exception as e:
        return False, f"Errore nella validazione: {str(e)}"


def compare_counts(watched_path: str, ratings_path: str, report_path: str) -> tuple[bool, str]:
    """Verifica la coerenza tra i file"""
    try:
        with open(watched_path, 'r') as f:
            watched = json.load(f)
        with open(ratings_path, 'r') as f:
            ratings = json.load(f)
        with open(report_path, 'r') as f:
            report = json.load(f)

        if len(watched) != report['watched_movies']:
            return False, f"Mismatch: watched-movies.json ha {len(watched)} film, report dice {report['watched_movies']}"

        if len(ratings) != report['rated_movies']:
            return False, f"Mismatch: ratings-movies.json ha {len(ratings)} film, report dice {report['rated_movies']}"

        return True, f"✓ Conteggi coerenti (watched: {len(watched)}, rated: {len(ratings)})"

    except Exception as e:
        return False, f"Errore nel confronto: {str(e)}"


def run_tests(output_dir: str = "./trakt_migration_output") -> bool:
    """Esegui tutti i test di validazione"""
    print("\n" + "="*60)
    print("TEST DI VALIDAZIONE DELLA MIGRAZIONE")
    print("="*60 + "\n")

    output_path = Path(output_dir)

    if not output_path.exists():
        print(f"❌ Directory di output non trovata: {output_dir}")
        return False

    # Test 1: watched-movies.json
    watched_file = output_path / "watched-movies.json"
    print(f"Test 1: Validazione watched-movies.json")
    if not watched_file.exists():
        print(f"  ❌ File non trovato: {watched_file}")
        return False
    success, message = validate_watched_movies(str(watched_file))
    print(f"  {'✓' if success else '❌'} {message}")
    if not success:
        return False

    # Test 2: ratings-movies.json
    ratings_file = output_path / "ratings-movies.json"
    print(f"\nTest 2: Validazione ratings-movies.json")
    if not ratings_file.exists():
        print(f"  ❌ File non trovato: {ratings_file}")
        return False
    success, message = validate_ratings_movies(str(ratings_file))
    print(f"  {'✓' if success else '❌'} {message}")
    if not success:
        return False

    # Test 3: migration-report.json
    report_file = output_path / "migration-report.json"
    print(f"\nTest 3: Validazione migration-report.json")
    if not report_file.exists():
        print(f"  ❌ File non trovato: {report_file}")
        return False
    success, message = validate_migration_report(str(report_file))
    print(f"  {'✓' if success else '❌'} {message}")
    if not success:
        return False

    # Test 4: Coerenza dei dati
    print(f"\nTest 4: Coerenza dei dati")
    success, message = compare_counts(
        str(watched_file),
        str(ratings_file),
        str(report_file)
    )
    print(f"  {'✓' if success else '❌'} {message}")
    if not success:
        return False

    # Stampa il report
    print("\n" + "="*60)
    print("RISULTATI MIGRAZIONE")
    print("="*60)
    with open(report_file, 'r') as f:
        report = json.load(f)

    print(f"Data migrazione: {report['migration_date']}")
    print(f"Film totali: {report['total_movies']}")
    print(f"Film visti: {report['watched_movies']}")
    print(f"Film valutati: {report['rated_movies']}")
    print(f"Valutazione media: {report['statistics']['average_rating']:.2f}/10")

    print("\n" + "="*60)
    print("✅ TUTTI I TEST SONO PASSATI!")
    print("="*60 + "\n")

    return True


if __name__ == "__main__":
    output_dir = "./trakt_migration_output"
    if len(sys.argv) > 1:
        output_dir = sys.argv[1]

    success = run_tests(output_dir)
    sys.exit(0 if success else 1)
