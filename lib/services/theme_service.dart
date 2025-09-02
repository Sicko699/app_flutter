import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  // Tema chiaro
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: Colors.blue,
      headerForegroundColor: Colors.white,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.black87;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue;
        }
        return Colors.transparent;
      }),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
  
  // Tema scuro
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: const Color(0xFF2D2D2D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: Colors.blue,
      headerForegroundColor: Colors.white,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.shade600;
        }
        return Colors.white;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue;
        }
        return Colors.transparent;
      }),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.white70;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue;
        }
        return Colors.transparent;
      }),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF2D2D2D),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
  
  // Inizializza il tema
  Future<void> initializeTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey);
      
      if (themeString != null) {
        _themeMode = _stringToThemeMode(themeString);
      } else {
        _themeMode = ThemeMode.system;
      }
      
      notifyListeners();
    } catch (e) {
      print("Errore durante il caricamento del tema: $e");
      print("Stack trace: ${StackTrace.current}");
      _themeMode = ThemeMode.system;
      notifyListeners();
    }
  }
  
  // Cambia il tema
  Future<void> changeTheme(ThemeMode themeMode) async {
    try {
      _themeMode = themeMode;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _themeModeToString(themeMode));
      
      notifyListeners();
    } catch (e) {
      print("Errore durante il cambio del tema: $e");
      print("Stack trace: ${StackTrace.current}");
    }
  }
  
  // Cambia il tema tramite stringa
  Future<void> changeThemeByString(String themeString) async {
    try {
      final themeMode = _stringToThemeMode(themeString);
      await changeTheme(themeMode);
    } catch (e) {
      print("Errore durante il cambio del tema tramite stringa: $e");
      // Fallback: cambia solo in memoria
      _themeMode = _stringToThemeMode(themeString);
      notifyListeners();
    }
  }
  
  // Converte ThemeMode in stringa
  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'chiaro';
      case ThemeMode.dark:
        return 'scuro';
      case ThemeMode.system:
        return 'sistema';
    }
  }
  
  // Converte stringa in ThemeMode
  ThemeMode _stringToThemeMode(String themeString) {
    switch (themeString.toLowerCase()) {
      case 'chiaro':
        return ThemeMode.light;
      case 'scuro':
        return ThemeMode.dark;
      case 'sistema':
      default:
        return ThemeMode.system;
    }
  }
  
  // Ottiene il nome del tema corrente
  String getCurrentThemeName() {
    return _themeModeToString(_themeMode);
  }
  
  // Ottiene la lista dei temi disponibili
  List<String> getAvailableThemes() {
    return ['sistema', 'chiaro', 'scuro'];
  }
  
  // Verifica se il tema è scuro
  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
} 