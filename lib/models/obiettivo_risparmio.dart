import 'package:flutter/material.dart';

class ObiettivoRisparmio {
  final String id;
  final String nome;
  final String icona; // Manteniamo come stringa per la serializzazione
  final String coloreIcona;
  final double importoTarget;
  final double importoAttuale;
  final String dataScadenza;
  final String profileId;
  final DateTime dataCreazione;
  final DateTime dataModifica;

  ObiettivoRisparmio({
    required this.id,
    required this.nome,
    required this.icona,
    required this.coloreIcona,
    required this.importoTarget,
    required this.importoAttuale,
    required this.dataScadenza,
    required this.profileId,
    required this.dataCreazione,
    required this.dataModifica,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'icona': icona,
      'coloreIcona': coloreIcona,
      'importoTarget': importoTarget,
      'importoAttuale': importoAttuale,
      'dataScadenza': dataScadenza,
      'profileId': profileId,
      'dataCreazione': dataCreazione.toIso8601String(),
      'dataModifica': dataModifica.toIso8601String(),
    };
  }

  factory ObiettivoRisparmio.fromMap(Map<String, dynamic> map) {
    return ObiettivoRisparmio(
      id: map['id']?.toString() ?? '', // Questo ora sarà doc.id dal servizio
      nome: map['nome']?.toString() ?? '',
      icona: map['icona']?.toString() ?? 'Savings',
      coloreIcona: map['coloreIcona']?.toString() ?? '#B0BEC5',
      importoTarget: _parseDouble(map['importoTarget']),
      importoAttuale: _parseDouble(map['importoAttuale']),
      dataScadenza: map['dataScadenza']?.toString() ?? '',
      profileId: map['profileId']?.toString() ?? '',
      dataCreazione: _parseDateTime(map['dataCreazione']),
      dataModifica: _parseDateTime(map['dataModifica']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        // Se il parsing fallisce, prova a parsare solo la data (YYYY-MM-DD)
        if (value.contains('-') && value.length == 10) {
          try {
            return DateTime.parse('${value}T00:00:00.000Z');
          } catch (e2) {
            return DateTime.now();
          }
        }
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  ObiettivoRisparmio copyWith({
    String? id,
    String? nome,
    String? icona,
    String? coloreIcona,
    double? importoTarget,
    double? importoAttuale,
    String? dataScadenza,
    String? profileId,
    DateTime? dataCreazione,
    DateTime? dataModifica,
  }) {
    return ObiettivoRisparmio(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      icona: icona ?? this.icona,
      coloreIcona: coloreIcona ?? this.coloreIcona,
      importoTarget: importoTarget ?? this.importoTarget,
      importoAttuale: importoAttuale ?? this.importoAttuale,
      dataScadenza: dataScadenza ?? this.dataScadenza,
      profileId: profileId ?? this.profileId,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataModifica: dataModifica ?? DateTime.now(),
    );
  }

  /// Calcola la percentuale di completamento
  double get percentualeCompletamento {
    if (importoTarget <= 0) return 0.0;
    return (importoAttuale / importoTarget * 100).clamp(0.0, 100.0);
  }

  /// Calcola l'importo rimanente
  double get importoRimanente {
    return (importoTarget - importoAttuale).clamp(0.0, double.infinity);
  }

  /// Verifica se l'obiettivo è completato
  bool get isCompletato {
    return importoAttuale >= importoTarget;
  }

  /// Verifica se l'obiettivo è in scadenza (entro 30 giorni)
  bool get isInScadenza {
    if (dataScadenza.isEmpty) return false;
    try {
      final scadenza = _parseDateTime(dataScadenza);
      final oggi = DateTime.now();
      final differenza = scadenza.difference(oggi).inDays;
      return differenza <= 30 && differenza >= 0;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se l'obiettivo è scaduto
  bool get isScaduto {
    if (dataScadenza.isEmpty) return false;
    try {
      final scadenza = _parseDateTime(dataScadenza);
      return DateTime.now().isAfter(scadenza);
    } catch (e) {
      return false;
    }
  }

  /// Converte la stringa dell'icona in IconData
  static IconData getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'savings':
        return Icons.savings;
      case 'car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'vacation':
        return Icons.flight;
      case 'gift':
        return Icons.card_giftcard;
      case 'education':
        return Icons.school;
      case 'health':
        return Icons.health_and_safety;
      case 'electronics':
        return Icons.devices;
      case 'clothing':
        return Icons.checkroom;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.savings;
    }
  }
}
