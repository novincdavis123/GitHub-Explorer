import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class RecentSearchStorage {
  static const String _boxName = 'recent_searches';
  static const String _searchesKey = 'usernames';
  static const int _maxSearches = 5;

  Future<Box<dynamic>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }

    return Hive.openBox<dynamic>(_boxName);
  }

  Future<List<String>> getRecentSearches() async {
    final box = await _getBox();

    final storedSearches = box.get(_searchesKey);

    if (storedSearches is! List) {
      return [];
    }

    return storedSearches.whereType<String>().toList();
  }

  Future<void> addSearch(String username) async {
    final trimmedUsername = username.trim();

    if (trimmedUsername.isEmpty) {
      return;
    }

    final box = await _getBox();

    final searches = await getRecentSearches();

    // Remove duplicate username, ignoring case.
    searches.removeWhere(
      (search) => search.toLowerCase() == trimmedUsername.toLowerCase(),
    );

    // Add latest search at the beginning.
    searches.insert(0, trimmedUsername);

    // Keep only the latest 5 searches.
    if (searches.length > _maxSearches) {
      searches.removeRange(_maxSearches, searches.length);
    }

    await box.put(_searchesKey, searches);
  }

  Future<void> clearSearches() async {
    final box = await _getBox();

    await box.delete(_searchesKey);
  }
}
