import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class OpenLibraryService {
  static const String _baseUrl = 'https://openlibrary.org';
  static final http.Client _client = http.Client();

  static Future<List<Book>> searchBooks({
    required String query,
    int page = 1,
    int limit = 20,
    String searchType = 'all',
  }) async {
    if (query.trim().isEmpty) return [];

    final encodedQuery = Uri.encodeComponent(query.trim());
    String urlString = '$_baseUrl/search.json?page=$page&limit=$limit';

    switch (searchType) {
      case 'title':
        urlString += '&title=$encodedQuery';
        break;
      case 'author':
        urlString += '&author=$encodedQuery';
        break;
      case 'subject':
        urlString += '&subject=$encodedQuery';
        break;
      default:
        urlString += '&q=$encodedQuery';
    }

    try {
      final response = await _client.get(Uri.parse(urlString));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> docs = data['docs'] ?? [];
        return docs.map((doc) => Book.fromJson(doc)).toList();
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<String?> fetchBookDescription(String workKey) async {
    final cleanKey = workKey.startsWith('/') ? workKey.substring(1) : workKey;
    final urlString = '$_baseUrl/$cleanKey.json';

    try {
      final response = await _client.get(Uri.parse(urlString));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final descriptionData = data['description'];

        if (descriptionData == null) {
          return 'No description available for this work.';
        }

        if (descriptionData is String) {
          return descriptionData;
        } else if (descriptionData is Map && descriptionData['value'] != null) {
          return descriptionData['value'].toString();
        }
        return 'No description available.';
      } else {
        return 'Failed to load description.';
      }
    } catch (e) {
      return 'Could not retrieve description.';
    }
  }

  static Future<double?> fetchBookRating(String workKey) async {
    final cleanKey = workKey.startsWith('/') ? workKey.substring(1) : workKey;
    final urlString = '$_baseUrl/$cleanKey/ratings.json';

    try {
      final response = await _client.get(Uri.parse(urlString));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final summary = data['summary'];
        if (summary != null && summary['average'] != null) {
          return (summary['average'] as num).toDouble();
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<int?> fetchBookPageCount(String workKey) async {
    final cleanKey = workKey.startsWith('/') ? workKey.substring(1) : workKey;
    final urlString = '$_baseUrl/$cleanKey/editions.json?limit=5';

    try {
      final response = await _client.get(Uri.parse(urlString));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> entries = data['entries'] ?? [];
        for (final entry in entries) {
          if (entry['number_of_pages'] != null) {
            return entry['number_of_pages'] as int;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<List<Book>> fetchBooksBySubject(String subject, {int limit = 15}) async {
    final cleanSubject = subject.toLowerCase().replaceAll(' ', '_');
    final urlString = '$_baseUrl/subjects/$cleanSubject.json?limit=$limit';

    try {
      final response = await _client.get(Uri.parse(urlString));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> works = data['works'] ?? [];

        return works.map((work) {
          final List<dynamic> authorsList = work['authors'] ?? [];
          final authors = authorsList.map((a) => a['name']?.toString() ?? 'Unknown Author').toList().cast<String>();

          return Book(
            key: work['key'] ?? '',
            title: work['title'] ?? 'Unknown Title',
            authors: authors,
            firstPublishYear: work['first_publish_year'],
            coverId: work['cover_id'],
            rating: null,
            isbn: [],
            pageCount: null,
            subjects: [subject],
          );
        }).toList();
      } else {
        throw Exception('Failed to load books for subject');
      }
    } catch (e) {
      rethrow;
    }
  }
}
