import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Favourites Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
