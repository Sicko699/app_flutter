import 'package:flutter/material.dart';

class DarkModeUtils {
  /// Ottiene il colore di sfondo appropriato per la dark mode
  static Color getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade50;
  }

  /// Ottiene il colore di sfondo per le varianti di superficie
  static Color getSurfaceVariantColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Theme.of(context).colorScheme.surfaceVariant : Colors.grey.shade50;
  }

  /// Ottiene il colore del bordo appropriato per la dark mode
  static Color getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade600 : Colors.grey.shade300;
  }

  /// Ottiene il colore del testo secondario appropriato per la dark mode
  static Color getSecondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  /// Ottiene il colore del bordo per i pulsanti outline
  static Color getOutlineBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade500 : Colors.grey.shade400;
  }

  /// Ottiene il colore di sfondo per i container di selezione
  static Color getSelectionBackgroundColor(BuildContext context, {Color? selectedColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (selectedColor != null) {
      return selectedColor.withOpacity(0.2);
    }
    return isDark ? Theme.of(context).colorScheme.surfaceVariant : Colors.grey.shade100;
  }

  /// Ottiene il colore di sfondo per i dialoghi di conferma
  static Color getDialogBackgroundColor(BuildContext context, {bool isError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isError) {
      return isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50;
    }
    return isDark ? Theme.of(context).colorScheme.surfaceVariant : Colors.grey.shade50;
  }

  /// Verifica se il tema corrente è dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Ottiene il colore di sfondo per i campi di input
  static Color getInputFillColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade50;
  }

  /// Ottiene il colore di sfondo per i campi di input con opacità
  static Color getInputFillColorWithOpacity(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Theme.of(context).colorScheme.surface.withOpacity(0.8) : Colors.grey.shade50;
  }
} 