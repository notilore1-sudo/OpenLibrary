import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';

class FavoritesService {
  static const String _favBoxName = 'favorites_box';
  static const String _histBoxName = 'history_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_favBoxName);
    await Hive.openBox(_histBoxName);
  }

  static List<Book> getFavorites() {
    final box = Hive.box(_favBoxName);
    return box.values.map((item) {
      return Book.fromMap(Map.from(item));
    }).toList();
  }

  static bool isFavorite(String key) {
    final box = Hive.box(_favBoxName);
    return box.containsKey(key);
  }

  static Future<bool> toggleFavorite(Book book) async {
    final box = Hive.box(_favBoxName);
    if (box.containsKey(book.key)) {
      await box.delete(book.key);
      return false;
    } else {
      await box.put(book.key, book.toMap());
      return true;
    }
  }

  static Future<void> saveFavorite(Book book) async {
    final box = Hive.box(_favBoxName);
    await box.put(book.key, book.toMap());
  }

  static List<String> getSearchHistory() {
    final box = Hive.box(_histBoxName);
    return List<String>.from(box.get('history', defaultValue: <String>[]) ?? []);
  }

  static Future<void> addSearchQuery(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    final box = Hive.box(_histBoxName);
    List<String> history = getSearchHistory();
    history.removeWhere((q) => q.toLowerCase() == cleanQuery.toLowerCase());
    history.insert(0, cleanQuery);

    if (history.length > 8) {
      history = history.sublist(0, 8);
    }

    await box.put('history', history);
  }

  static Future<void> clearSearchHistory() async {
    final box = Hive.box(_histBoxName);
    await box.delete('history');
  }
}
