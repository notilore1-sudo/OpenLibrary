# LibriVerse

LibriVerse to nowoczesna aplikacja mobilna stworzona w technologii Flutter, służąca do przeglądania i wyszukiwania książek za pomocą integracji z publicznym interfejsem REST API **Open Library**.

## Funkcjonalności

*   **Katalog Online z podziałem na kategorie**: Użytkownik może przeglądać książki pogrupowane w popularne kategorie tematyczne (Sci-Fi, Fantasy, Romance, History, Mystery).
*   **Szczegóły Książki**: Widok szczegółowy prezentuje pełne informacje o wybranym tytule (okładka, autorzy, ocena, rok wydania, liczba stron, gatunki oraz opis/synopsis pobierany bezpośrednio z API).
*   **Tryb Offline (Moja Półka)**: Aplikacja umożliwia dodawanie książek do ulubionych. Dane książek są zapisywane lokalnie w bazie danych **Hive**, co pozwala na pełen dostęp do zapisanych pozycji bez połączenia z internetem.
*   **Obsługa stanów ładowania**: Podczas pobierania danych z API wyświetlany jest estetyczny szkielet ładowania (Shimmer skeleton loader).
*   **Obsługa błędów**: W przypadku braku połączenia internetowego lub błędu serwera, aplikacja wyświetla czytelny komunikat dla użytkownika z możliwością ponowienia próby.

## Stos Technologiczny

*   **Framework**: Flutter & Dart
*   **Komunikacja sieciowa**: HTTP (REST API Open Library)
*   **Lokalna baza danych (Offline)**: Hive & Hive Flutter
*   **Biblioteki pomocnicze**: Shimmer (efekt ładowania)
