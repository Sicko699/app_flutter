import 'package:flutter/material.dart';

class IconUtils {
  /// Converte il nome dell'icona dall'app Kotlin in IconData di Flutter
  /// Soluzione semplice e diretta per compatibilità tra app
  static IconData getIconFromName(String iconName) {
    
    switch (iconName) {
      case 'Fastfood': return Icons.fastfood;
      case 'Savings': return Icons.savings;
      case 'School': return Icons.school;
      case 'Favorite': return Icons.favorite;
      case 'Home': return Icons.home;
      case 'CarRental': return Icons.car_rental;
      case 'Flight': return Icons.flight;
      case 'FitnessCenter': return Icons.fitness_center;
      case 'LocalDrink': return Icons.local_drink;
      case 'ShoppingCart': return Icons.shopping_cart;
      case 'LocalGasStation': return Icons.local_gas_station;
      case 'LocalHospital': return Icons.local_hospital;
      case 'LocalPharmacy': return Icons.local_pharmacy;
      case 'Movie': return Icons.movie;
      case 'MusicNote': return Icons.music_note;
      case 'Pets': return Icons.pets;
      case 'DirectionsBus': return Icons.directions_bus;
      case 'ElectricBolt': return Icons.electric_bolt;
      case 'Checkroom': return Icons.checkroom;
      case 'AccountBalance': return Icons.account_balance;
      case 'CreditCard': return Icons.credit_card;
      case 'Restaurant': return Icons.restaurant;
      case 'Coffee': return Icons.local_cafe;
      case 'LocalGroceryStore': return Icons.local_grocery_store;
      case 'Build': return Icons.build;
      case 'Phone': return Icons.phone;
      default: 
        return Icons.shopping_cart;
    }
  }

  /// Metodo legacy per compatibilità (usa getIconFromName)
  @Deprecated('Usa getIconFromName invece')
  static IconData getIconData(String iconName) {
    return getIconFromName(iconName);
  }

  /// Lista di tutte le icone disponibili per il picker
  static const List<String> availableIcons = [
    'Fastfood', 'Savings', 'School', 'Favorite', 'Home',
    'CarRental', 'Flight', 'FitnessCenter', 'LocalDrink',
    'ShoppingCart', 'LocalGasStation', 'LocalHospital', 
    'LocalPharmacy', 'Movie', 'MusicNote', 'Pets', 
    'DirectionsBus', 'ElectricBolt', 'Checkroom', 
    'AccountBalance', 'CreditCard', 'Restaurant', 'Coffee', 
    'LocalGroceryStore', 'Build', 'Phone'
  ];

  /// Converte codePoint numerico (formato Flutter) in nome icona (formato Kotlin)
  static String codePointToIconName(String codePoint) {
    try {
      int code = int.parse(codePoint);
      
      // Mapping dei codePoint più comuni alle icone
      switch (code) {
        case 58780: return 'ShoppingCart';
        case 57690: return 'Home';
        case 57524: return 'Fastfood';
        case 58732: return 'Restaurant';
        case 57434: return 'CarRental';
        case 58659: return 'Flight';
        case 58731: return 'Savings';
        case 58459: return 'School';
        case 57686: return 'Favorite';
        case 58570: return 'LocalDrink';
        case 58571: return 'LocalGasStation';
        case 58572: return 'LocalHospital';
        case 58576: return 'LocalPharmacy';
        case 58615: return 'Movie';
        case 58622: return 'MusicNote';
        case 58677: return 'Pets';
        case 57498: return 'DirectionsBus';
        case 58295: return 'ElectricBolt';
        case 57483: return 'Checkroom';
        case 59224: return 'AccountBalance';
        case 57556: return 'CreditCard';
        case 58568: return 'Coffee';
        case 58569: return 'LocalGroceryStore';
        case 57491: return 'Build';
        case 57534: return 'Phone';
        default:
          return 'ShoppingCart'; // Default fallback
      }
    } catch (e) {
      return 'ShoppingCart'; // Default fallback se parsing fallisce
    }
  }

  /// Converte nome icona (formato Kotlin) in codePoint numerico (formato Flutter)
  static String iconNameToCodePoint(String iconName) {
    switch (iconName) {
      case 'ShoppingCart': return '58780';
      case 'Home': return '57690';
      case 'Fastfood': return '57524';
      case 'Restaurant': return '58732';
      case 'CarRental': return '57434';
      case 'Flight': return '58659';
      case 'Savings': return '58731';
      case 'School': return '58459';
      case 'Favorite': return '57686';
      case 'LocalDrink': return '58570';
      case 'LocalGasStation': return '58571';
      case 'LocalHospital': return '58572';
      case 'LocalPharmacy': return '58576';
      case 'Movie': return '58615';
      case 'MusicNote': return '58622';
      case 'Pets': return '58677';
      case 'DirectionsBus': return '57498';
      case 'ElectricBolt': return '58295';
      case 'Checkroom': return '57483';
      case 'AccountBalance': return '59224';
      case 'CreditCard': return '57556';
      case 'Coffee': return '58568';
      case 'LocalGroceryStore': return '58569';
      case 'Build': return '57491';
      case 'Phone': return '57534';
      default:
        return '58780'; // Default fallback to ShoppingCart
    }
  }
}   