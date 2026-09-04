#!/usr/bin/env python3
"""
Smart Film Matcher - Abbina film di Cinemaniac con film di Trakt usando fuzzy matching
Non richiede API Key, usa solo i dati che hai già!
"""

import json
from difflib import SequenceMatcher
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional, Any


class SmartFilmMatcher:
    def __init__(self, cinemaniac_backup: str, trakt_export_dir: str):
        self.cinemaniac = self._load_cinemaniac(cinemaniac_backup)
        self.trakt_movies = self._load_trakt_movies(trakt_export_dir)
        self.matches = {}
        self.unmatched = []

    def _load_cinemaniac(self, filepath: str) -> List[Dict[str, Any]]:
        """Carica i film da Cinemaniac"""
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return data.get('movies', [])

    def _load_trakt_movies(self, trakt_dir: str) -> Dict[str, Dict[str, Any]]:
        """Carica i film da Trakt e crea un indice per ricerca veloce"""
        movies_by_title = {}
        trakt_files = [
            Path(trakt_dir) / 'watched-movies.json',
            Path(trakt_dir) / 'ratings-movies.json'
        ]

        for trakt_file in trakt_files:
            if not trakt_file.exists():
                continue

            with open(trakt_file, 'r', encoding='utf-8') as f:
                data = json.load(f)

            for entry in data:
                movie = entry.get('movie', {})
                title = movie.get('title', '')
                year = movie.get('year')
                ids = movie.get('ids', {})

                # Crea chiave univoca title + year
                key = f"{title}_{year}"
                if key not in movies_by_title:
                    movies_by_title[key] = {
                        'title': title,
                        'year': year,
                        'ids': ids,
                        'entry': entry
                    }

        return movies_by_title

    def _similarity(self, a: str, b: str) -> float:
        """Calcola la similarità tra due stringhe (0-1)"""
        return SequenceMatcher(None, a.lower(), b.lower()).ratio()

    def _extract_year_from_timestamp(self, timestamp_ms: int) -> Optional[int]:
        """Estrae l'anno dal timestamp di Cinemaniac"""
        try:
            if timestamp_ms == 0:
                return None
            # Converti da millisecondi a secondi e calcola l'anno
            year = int(timestamp_ms / 1000 / 60 / 60 / 24 / 365.25 + 1970)
            if 1900 <= year <= 2100:
                return year
            return None
        except:
            return None

    def find_match(self, cinemaniac_movie: Dict[str, Any]) -> Tuple[Optional[Dict[str, Any]], float]:
        """
        Trova il miglior match per un film di Cinemaniac
        Ritorna (film_trovato, confidence_score)
        """
        cine_title = cinemaniac_movie.get('title', '').strip()
        cine_year = self._extract_year_from_timestamp(cinemaniac_movie.get('year', 0))

        if not cine_title:
            return None, 0.0

        best_match = None
        best_score = 0.0

        # Ricerca tra i film di Trakt
        for trakt_entry in self.trakt_movies.values():
            trakt_title = trakt_entry['title']
            trakt_year = trakt_entry['year']

            # Calcola similarità titolo
            title_similarity = self._similarity(cine_title, trakt_title)

            # Se gli anni sono entrambi disponibili, verifica la corrispondenza
            year_match = 1.0 if cine_year is None or trakt_year is None or cine_year == trakt_year else 0.0

            # Score combinato: 70% da titolo, 30% da anno
            if cine_year and trakt_year:
                score = title_similarity * 0.7 + year_match * 0.3
            else:
                score = title_similarity

            # Aggiorna il miglior match se la similarità è sufficientemente alta
            if score > best_score and score >= 0.75:  # Soglia di fiducia
                best_score = score
                best_match = trakt_entry

        return best_match, best_score

    def match_all(self) -> Dict[str, int]:
        """Abbina tutti i film e ritorna le statistiche"""
        print("🔍 Matching in corso...\n")

        stats = {
            'total': len(self.cinemaniac),
            'matched': 0,
            'unmatched': 0,
            'high_confidence': 0,
            'medium_confidence': 0,
            'low_confidence': 0
        }

        for i, cine_movie in enumerate(self.cinemaniac):
            title = cine_movie.get('title', 'Unknown')
            trakt_movie, score = self.find_match(cine_movie)

            if trakt_movie:
                self.matches[cine_movie['id_movie']] = {
                    'cinemaniac': cine_movie,
                    'trakt': trakt_movie,
                    'confidence': score
                }
                stats['matched'] += 1

                if score >= 0.95:
                    stats['high_confidence'] += 1
                    confidence_label = "🟢"
                elif score >= 0.85:
                    stats['medium_confidence'] += 1
                    confidence_label = "🟡"
                else:
                    stats['low_confidence'] += 1
                    confidence_label = "🟠"

                print(f"[{i+1}/{len(self.cinemaniac)}] {confidence_label} ({score:.0%}) {title}")
            else:
                self.unmatched.append(cine_movie)
                stats['unmatched'] += 1
                print(f"[{i+1}/{len(self.cinemaniac)}] ❌ {title}")

        return stats

    def generate_trakt_import(self) -> Tuple[List[Dict], List[Dict]]:
        """
        Genera i file pronti per l'importazione in Trakt
        Ritorna (watched_movies, ratings_movies)
        """
        watched_movies = []
        ratings_movies = []

        for match_data in self.matches.values():
            trakt_entry = match_data['trakt']['entry']
            cine_movie = match_data['cinemaniac']
            rating = cine_movie.get('rating', 0)

            # Aggiungi a watched-movies
            watched_movies.append(trakt_entry)

            # Aggiungi a ratings-movies se ha valutazione
            if rating > 0:
                # Converti la valutazione a scala 1-10
                trakt_rating = min(10, max(1, int(rating)))

                rating_entry = {
                    'rated_at': datetime.utcnow().isoformat() + '.000Z',
                    'rating': trakt_rating,
                    'type': 'movie',
                    'movie': trakt_entry['movie']
                }
                ratings_movies.append(rating_entry)

        return watched_movies, ratings_movies

    def save_results(self, output_dir: str) -> None:
        """Salva i file pronti per l'importazione in Trakt"""
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)

        watched_movies, ratings_movies = self.generate_trakt_import()

        # Salva watched-movies.json
        watched_file = output_path / 'watched-movies.json'
        with open(watched_file, 'w', encoding='utf-8') as f:
            json.dump(watched_movies, f, indent=2, ensure_ascii=False)
        print(f"\n✅ Salvato: {watched_file}")

        # Salva ratings-movies.json
        ratings_file = output_path / 'ratings-movies.json'
        with open(ratings_file, 'w', encoding='utf-8') as f:
            json.dump(ratings_movies, f, indent=2, ensure_ascii=False)
        print(f"✅ Salvato: {ratings_file}")

        # Salva film non abbinati per revisione manuale
        if self.unmatched:
            unmatched_file = output_path / 'unmatched-films.json'
            with open(unmatched_file, 'w', encoding='utf-8') as f:
                json.dump(self.unmatched, f, indent=2, ensure_ascii=False)
            print(f"⚠️  Salvato (film non trovati): {unmatched_file}")

        # Salva il report
        report = {
            'matching_date': datetime.utcnow().isoformat(),
            'source': 'Cinemaniac',
            'destination': 'Trakt',
            'total_films': len(self.cinemaniac),
            'matched': len(self.matches),
            'unmatched': len(self.unmatched),
            'success_rate': f"{100 * len(self.matches) / len(self.cinemaniac):.1f}%",
            'files_ready_for_import': [
                'watched-movies.json',
                'ratings-movies.json'
            ],
            'instructions': 'Carica questi file in Trakt: https://trakt.tv/settings/data'
        }

        report_file = output_path / 'matching-report.json'
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        print(f"📊 Salvato report: {report_file}")


def main():
    import sys

    if len(sys.argv) < 4:
        print("Uso: python3 smart_film_matcher.py <Cinemaniac.bak> <trakt_export_dir> <output_dir>")
        print("\nEsempio:")
        print("  python3 smart_film_matcher.py Cinemaniac.bak ./trakt_export ./trakt_ready_to_import")
        sys.exit(1)

    cinemaniac_file = sys.argv[1]
    trakt_dir = sys.argv[2]
    output_dir = sys.argv[3]

    # Verifica i file
    if not Path(cinemaniac_file).exists():
        print(f"❌ Errore: {cinemaniac_file} non trovato")
        sys.exit(1)

    if not Path(trakt_dir).exists():
        print(f"❌ Errore: {trakt_dir} non trovato")
        sys.exit(1)

    print("="*70)
    print("SMART FILM MATCHER - Abbinamento Cinemaniac ↔ Trakt")
    print("="*70)

    try:
        matcher = SmartFilmMatcher(cinemaniac_file, trakt_dir)
        stats = matcher.match_all()

        print("\n" + "="*70)
        print("📊 STATISTICHE DI ABBINAMENTO")
        print("="*70)
        print(f"Film totali: {stats['total']}")
        print(f"Film abbinati: {stats['matched']} ✓")
        print(f"Film non abbinati: {stats['unmatched']} ✗")
        print(f"Tasso di successo: {100*stats['matched']/stats['total']:.1f}%")
        print(f"\nAbbinamenti ad alta fiducia (>95%): {stats['high_confidence']} 🟢")
        print(f"Abbinamenti a media fiducia (85-95%): {stats['medium_confidence']} 🟡")
        print(f"Abbinamenti a bassa fiducia (<85%): {stats['low_confidence']} 🟠")

        print("\n" + "="*70)
        print("💾 GENERAZIONE FILE PER TRAKT")
        print("="*70)

        matcher.save_results(output_dir)

        print("\n" + "="*70)
        print("✅ PRONTO PER L'IMPORTAZIONE!")
        print("="*70)
        print(f"\n1. Vai a: https://trakt.tv/settings/data")
        print(f"2. Carica i file da: {output_dir}/")
        print(f"   - watched-movies.json")
        print(f"   - ratings-movies.json")
        print(f"\n3. I film verranno importati nel tuo account Trakt")
        print("="*70 + "\n")

    except Exception as e:
        print(f"❌ Errore: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
