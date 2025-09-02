import 'package:flutter/material.dart';

class ColorUtils {
  /// Lista dei colori vibranti dell'app Kotlin
  static const List<Color> vibrantColors = [
    Color(0xFFE53E3E), // Rosso vibrante
    Color(0xFFFF6B6B), // Rosa-rosso vivace
    Color(0xFFFF9500), // Arancione brillante
    Color(0xFFFFD60A), // Giallo vivace
    Color(0xFF30D158), // Verde lime
    Color(0xFF00C896), // Verde turchese
    Color(0xFF007AFF), // Blu elettrico
    Color(0xFF5856D6), // Viola intenso
    Color(0xFFAF52DE), // Magenta vibrante
    Color(0xFFFF2D92), // Rosa shocking
    Color(0xFF00D7FF), // Ciano brillante
    Color(0xFF66CC99), // Verde menta
    Color(0xFFFF6B35), // Arancione corallo
    Color(0xFFFF3366), // Rosa elettrico
    Color(0xFF8B5CF6), // Viola lavanda
    Color(0xFFEF4444), // Rosso cremisi
  ];

  /// Converte un colore esadecimale (es. #81D4FA) in un Color di Flutter
  /// Soluzione semplice e diretta
  static Color hexToColor(String hexColor) {
    try {
      // Rimuovi il # se presente
      String hex = hexColor.replaceAll('#', '');
      
      // Verifica che sia un colore esadecimale valido
      if (!RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(hex)) {
        return vibrantColors.first; // Fallback al primo colore vibrante
      }
      
      // Aggiungi 0xFF per l'opacità
      hex = '0xFF$hex';
      
      // Converti in intero e crea il Color
      return Color(int.parse(hex));
    } catch (e) {
      // Fallback al primo colore vibrante se la conversione fallisce
      return vibrantColors.first;
    }
  }

  /// Converte un Color di Flutter in formato esadecimale
  static String colorToHex(Color color) {
    int r = (color.r * 255.0).round() & 0xff;
    int g = (color.g * 255.0).round() & 0xff;
    int b = (color.b * 255.0).round() & 0xff;
    return '#${(r << 16 | g << 8 | b).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// Verifica se una stringa è un colore esadecimale valido
  static bool isValidHexColor(String color) {
    if (color.isEmpty) return false;
    
    // Rimuovi il # se presente
    String hex = color.replaceAll('#', '');
    
    // Deve essere di 6 caratteri e contenere solo caratteri esadecimali
    return hex.length == 6 && RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(hex);
  }

  /// Ottiene un colore vibrante casuale
  static Color getRandomVibrantColor() {
    return vibrantColors[DateTime.now().millisecond % vibrantColors.length];
  }

  /// Ottiene un colore vibrante per indice
  static Color getVibrantColor(int index) {
    return vibrantColors[index % vibrantColors.length];
  }

  /// Converte un valore numerico (formato Flutter) in colore hex (formato Kotlin)
  static String colorValueToHex(String colorValue) {
    try {
      int value = int.parse(colorValue);
      
      // Rimuovi la componente alpha e converti in hex
      String hex = (value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
      return '#$hex';
    } catch (e) {
      // Fallback a un colore di default se la conversione fallisce
      return '#E082FF'; // Colore viola di default
    }
  }

  /// Converte un colore hex (formato Kotlin) in valore numerico (formato Flutter)
  static String hexToColorValue(String hexColor) {
    try {
      // Rimuovi il # se presente
      String hex = hexColor.replaceAll('#', '');
      
      // Verifica che sia un colore esadecimale valido
      if (!RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(hex)) {
        return '4294198070'; // Fallback al valore di default
      }
      
      // Aggiungi la componente alpha FF (opaco) e converti
      int value = int.parse('FF$hex', radix: 16);
      return value.toString();
    } catch (e) {
      return '4294198070'; // Fallback al valore di default se la conversione fallisce
    }
  }
}
