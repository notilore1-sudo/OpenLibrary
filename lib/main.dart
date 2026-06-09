import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/favorites_service.dart';
import 'screens/catalog_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FavoritesService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LibriVerse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
          primary: Colors.teal[800],
          secondary: Colors.tealAccent[700],
          surface: Colors.grey[50]!,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme).copyWith(
          titleLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.outfit(
            color: Colors.black87,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
          primary: Colors.teal[300],
          secondary: Colors.tealAccent[200],
          surface: const Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF0a0a0a),
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme).copyWith(
          titleLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: GoogleFonts.outfit(
            color: const Color(0xE6FFFFFF),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const CatalogScreen(),
    );
  }
}
