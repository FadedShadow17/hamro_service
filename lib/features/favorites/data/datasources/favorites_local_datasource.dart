import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_service_model.dart';

abstract class FavoritesLocalDataSource {
  Future<List<FavoriteServiceModel>> getFavorites();
  Future<void> addFavorite(String serviceId);
  Future<void> removeFavorite(String serviceId);
  Future<bool> isFavorite(String serviceId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences _prefs;
  static const String _favoritesKey = 'favorite_services';

  FavoritesLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<List<FavoriteServiceModel>> getFavorites() async {
    final favoritesJson = _prefs.getString(_favoritesKey);
    if (favoritesJson == null || favoritesJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList
          .map((json) => FavoriteServiceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addFavorite(String serviceId) async {
    final favorites = await getFavorites();
    
    if (favorites.any((f) => f.serviceId == serviceId)) {
      return;
    }

    final newFavorite = FavoriteServiceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceId: serviceId,
      addedAt: DateTime.now(),
    );

    favorites.add(newFavorite);
    await _saveFavorites(favorites);
  }

  @override
  Future<void> removeFavorite(String serviceId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((f) => f.serviceId == serviceId);
    await _saveFavorites(favorites);
  }

  @override
  Future<bool> isFavorite(String serviceId) async {
    final favorites = await getFavorites();
    return favorites.any((f) => f.serviceId == serviceId);
  }

  Future<void> _saveFavorites(List<FavoriteServiceModel> favorites) async {
    final favoritesJson = json.encode(
      favorites.map((f) => f.toJson()).toList(),
    );
    await _prefs.setString(_favoritesKey, favoritesJson);
  }
}
