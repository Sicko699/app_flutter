import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:track_that_flutter/utils/color_utils.dart';

void main() {
  group('ColorUtils Tests', () {
    test('hexToColor should convert valid hex colors correctly', () {
      // Test con colore esadecimale standard
      final color1 = ColorUtils.hexToColor('#FF0000');
      expect(color1, equals(Color(0xFFFF0000)));
      
      // Test con colore esadecimale senza #
      final color2 = ColorUtils.hexToColor('00FF00');
      expect(color2, equals(Color(0xFF00FF00)));
      
      // Test con colore esadecimale blu
      final color3 = ColorUtils.hexToColor('#0000FF');
      expect(color3, equals(Color(0xFF0000FF)));
    });

    test('hexToColor should handle invalid colors gracefully', () {
      // Test con stringa vuota
      final color1 = ColorUtils.hexToColor('');
      expect(color1, equals(ColorUtils.vibrantColors.first));
      
      // Test con stringa non valida
      final color2 = ColorUtils.hexToColor('invalid');
      expect(color2, equals(ColorUtils.vibrantColors.first));
      
      // Test con stringa troppo corta
      final color3 = ColorUtils.hexToColor('123');
      expect(color3, equals(ColorUtils.vibrantColors.first));
      
      // Test con stringa troppo lunga
      final color4 = ColorUtils.hexToColor('1234567');
      expect(color4, equals(ColorUtils.vibrantColors.first));
    });

    test('colorToHex should convert Color to hex string', () {
      final color = Color(0xFFFF0000); // Rosso puro
      final hex = ColorUtils.colorToHex(color);
      expect(hex, equals('#FF0000'));
      
      final color2 = Color(0xFF00FF00); // Verde puro
      final hex2 = ColorUtils.colorToHex(color2);
      expect(hex2, equals('#00FF00'));
      
      final color3 = Color(0xFF0000FF); // Blu puro
      final hex3 = ColorUtils.colorToHex(color3);
      expect(hex3, equals('#0000FF'));
    });

    test('isValidHexColor should validate hex colors correctly', () {
      // Colori validi
      expect(ColorUtils.isValidHexColor('#FF0000'), isTrue);
      expect(ColorUtils.isValidHexColor('00FF00'), isTrue);
      expect(ColorUtils.isValidHexColor('0000FF'), isTrue);
      expect(ColorUtils.isValidHexColor('#abcdef'), isTrue);
      expect(ColorUtils.isValidHexColor('ABCDEF'), isTrue);
      
      // Colori non validi
      expect(ColorUtils.isValidHexColor(''), isFalse);
      expect(ColorUtils.isValidHexColor('invalid'), isFalse);
      expect(ColorUtils.isValidHexColor('123'), isFalse);
      expect(ColorUtils.isValidHexColor('12345'), isFalse);
      expect(ColorUtils.isValidHexColor('1234567'), isFalse);
      expect(ColorUtils.isValidHexColor('#12345'), isFalse);
      expect(ColorUtils.isValidHexColor('#1234567'), isFalse);
    });

    test('vibrantColors should contain expected colors', () {
      // Verifica che la lista contenga i colori principali
      expect(ColorUtils.vibrantColors.length, equals(16));
      expect(ColorUtils.vibrantColors.first, isA<Color>());
      expect(ColorUtils.vibrantColors.last, isA<Color>());
    });

    test('getRandomVibrantColor should return a valid color', () {
      final color = ColorUtils.getRandomVibrantColor();
      expect(ColorUtils.vibrantColors, contains(color));
    });

    test('getVibrantColor should return colors by index', () {
      final color1 = ColorUtils.getVibrantColor(0);
      expect(color1, equals(ColorUtils.vibrantColors[0]));
      
      final color2 = ColorUtils.getVibrantColor(5);
      expect(color2, equals(ColorUtils.vibrantColors[5]));
      
      // Test con indice che supera la lunghezza
      final color3 = ColorUtils.getVibrantColor(20);
      expect(color3, equals(ColorUtils.vibrantColors[4])); // 20 % 16 = 4
    });
  });
}
