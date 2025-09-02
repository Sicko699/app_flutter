import 'package:flutter/material.dart';

class OnboardingConstants {
  // Icone disponibili (32 icone)
  static const List<IconData> availableIcons = [
    Icons.home,
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.directions_car,
    Icons.local_gas_station,
    Icons.medical_services,
    Icons.school,
    Icons.work,
    Icons.sports_esports,
    Icons.movie,
    Icons.music_note,
    Icons.fitness_center,
    Icons.local_bar,
    Icons.local_cafe,
    Icons.flight,
    Icons.hotel,
    Icons.local_pharmacy,
    Icons.local_grocery_store,
    Icons.local_mall,
    Icons.local_laundry_service,
    Icons.local_taxi,
    Icons.local_parking,
    Icons.local_atm,
    Icons.account_balance,
    Icons.credit_card,
    Icons.savings,
    Icons.trending_up,
    Icons.trending_down,
    Icons.attach_money,
    Icons.monetization_on,
    Icons.account_balance_wallet,
    Icons.payment,
  ];

  // Colori disponibili (32 colori)
  static const List<Color> availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.redAccent,
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.deepPurpleAccent,
    Colors.indigoAccent,
    Colors.blueAccent,
    Colors.lightBlueAccent,
    Colors.cyanAccent,
    Colors.tealAccent,
    Colors.greenAccent,
    Colors.lightGreenAccent,
    Colors.limeAccent,
  ];

  // Tipi di conto disponibili
  static const List<String> tipiConto = [
    'Contanti',
    'Conto',
    'Carta',
    'Investimento',
  ];

  // Ottiene il nome dell'icona
  static String getIconName(IconData icon) {
    switch (icon) {
      case Icons.home: return 'Casa';
      case Icons.shopping_cart: return 'Shopping';
      case Icons.restaurant: return 'Ristorante';
      case Icons.directions_car: return 'Auto';
      case Icons.local_gas_station: return 'Benzina';
      case Icons.medical_services: return 'Salute';
      case Icons.school: return 'Istruzione';
      case Icons.work: return 'Lavoro';
      case Icons.sports_esports: return 'Gaming';
      case Icons.movie: return 'Cinema';
      case Icons.music_note: return 'Musica';
      case Icons.fitness_center: return 'Fitness';
      case Icons.local_bar: return 'Bar';
      case Icons.local_cafe: return 'Caffè';
      case Icons.flight: return 'Viaggi';
      case Icons.hotel: return 'Hotel';
      case Icons.local_pharmacy: return 'Farmacia';
      case Icons.local_grocery_store: return 'Supermercato';
      case Icons.local_mall: return 'Centro Commerciale';
      case Icons.local_laundry_service: return 'Lavanderia';
      case Icons.local_taxi: return 'Taxi';
      case Icons.local_parking: return 'Parcheggio';
      case Icons.local_atm: return 'ATM';
      case Icons.account_balance: return 'Banca';
      case Icons.credit_card: return 'Carta';
      case Icons.savings: return 'Risparmio';
      case Icons.trending_up: return 'Investimenti';
      case Icons.trending_down: return 'Spese';
      case Icons.attach_money: return 'Denaro';
      case Icons.monetization_on: return 'Guadagni';
      case Icons.account_balance_wallet: return 'Portafoglio';
      case Icons.payment: return 'Pagamenti';
      default: return 'Icona';
    }
  }

  // Ottiene il nome del colore
  static String getColorName(Color color) {
    if (color == Colors.red) return 'Rosso';
    if (color == Colors.pink) return 'Rosa';
    if (color == Colors.purple) return 'Viola';
    if (color == Colors.deepPurple) return 'Viola Scuro';
    if (color == Colors.indigo) return 'Indaco';
    if (color == Colors.blue) return 'Blu';
    if (color == Colors.lightBlue) return 'Blu Chiaro';
    if (color == Colors.cyan) return 'Ciano';
    if (color == Colors.teal) return 'Verde Acqua';
    if (color == Colors.green) return 'Verde';
    if (color == Colors.lightGreen) return 'Verde Chiaro';
    if (color == Colors.lime) return 'Lime';
    if (color == Colors.yellow) return 'Giallo';
    if (color == Colors.amber) return 'Ambra';
    if (color == Colors.orange) return 'Arancione';
    if (color == Colors.deepOrange) return 'Arancione Scuro';
    if (color == Colors.brown) return 'Marrone';
    if (color == Colors.grey) return 'Grigio';
    if (color == Colors.blueGrey) return 'Grigio Blu';
    if (color == Colors.black) return 'Nero';
    return 'Colore';
  }
} 