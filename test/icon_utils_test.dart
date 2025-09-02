import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:track_that_flutter/utils/icon_utils.dart';

void main() {
  group('IconUtils Tests', () {
    test('getIconFromName should return correct icons for Kotlin app names', () {
      // Test con nomi di icone dell'app Kotlin
      final homeIcon = IconUtils.getIconFromName('Home');
      expect(homeIcon, equals(Icons.home));
      
      final workIcon = IconUtils.getIconFromName('Build');
      expect(workIcon, equals(Icons.build));
      
      final shoppingIcon = IconUtils.getIconFromName('ShoppingCart');
      expect(shoppingIcon, equals(Icons.shopping_cart));
      
      final localDrinkIcon = IconUtils.getIconFromName('LocalDrink');
      expect(localDrinkIcon, equals(Icons.local_drink));
    });

    test('getIconFromName should handle unknown icons gracefully', () {
      // Test con nomi di icone sconosciuti
      final unknownIcon = IconUtils.getIconFromName('UnknownIcon');
      expect(unknownIcon, equals(Icons.shopping_cart)); // Fallback
      
      final emptyIcon = IconUtils.getIconFromName('');
      expect(emptyIcon, equals(Icons.shopping_cart)); // Fallback
    });

    test('availableIcons should contain all expected icons', () {
      // Verifica che la lista contenga tutte le icone principali
      expect(IconUtils.availableIcons, contains('Home'));
      expect(IconUtils.availableIcons, contains('ShoppingCart'));
      expect(IconUtils.availableIcons, contains('LocalDrink'));
      expect(IconUtils.availableIcons, contains('Fastfood'));
      expect(IconUtils.availableIcons, contains('Savings'));
      
      // Verifica che non ci siano duplicati
      final uniqueIcons = IconUtils.availableIcons.toSet();
      expect(uniqueIcons.length, equals(IconUtils.availableIcons.length));
    });

    test('getIconData should work as legacy method', () {
      // Test del metodo legacy per compatibilità
      final homeIcon = IconUtils.getIconData('Home');
      expect(homeIcon, equals(Icons.home));
      
      final shoppingIcon = IconUtils.getIconData('ShoppingCart');
      expect(shoppingIcon, equals(Icons.shopping_cart));
    });
  });
}
