import 'package:shared_preferences/shared_preferences.dart';

Future<void> addFavorite(String? uri) async {
  final prefs = await SharedPreferences.getInstance();
  final favorites = prefs.getStringList('favorites') ?? [];
  if (!favorites.contains(uri)) {
    favorites.add(uri!);
    await prefs.setStringList('favorites', favorites);
  }
}

Future<bool> isFavorite(String? uri) async {
  final prefs = await SharedPreferences.getInstance();
  final favorites = prefs.getStringList('favorites') ?? [];
  return favorites.contains(uri);
}

Future<List<String>> getFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('favorites') ?? [];
}

Future<void> removeFavorite(String? uri) async {
  final prefs = await SharedPreferences.getInstance();
  final favorites = prefs.getStringList('favorites') ?? [];
  if (favorites.contains(uri)) {
    favorites.remove(uri);
    await prefs.setStringList('favorites', favorites);
  }
}
