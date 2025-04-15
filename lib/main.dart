import 'package:bussin/pages/favorites.dart';
import 'package:bussin/pages/home.dart';
import 'package:bussin/utils/constants.dart';

import 'services/database_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initDb();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "bussin",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              spreadRadius: 0,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: Colors.red.withValues(alpha: 0.1),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedIndex: currentPageIndex,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          height: 65,
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.restaurant, color: mcdColor),
              icon: Icon(Icons.restaurant_outlined, color: Colors.grey[600]),
              label: 'Meals',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.favorite, color: mcdColor),
              icon: Icon(
                Icons.favorite_border_outlined,
                color: Colors.grey[600],
              ),
              label: 'Favorites',
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: <Widget>[HomePage(), FavoritesPage()][currentPageIndex],
      ),
    );
  }
}
