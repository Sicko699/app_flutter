class Transazione {
  final String id;
  final String titolo;
  final String descrizione;
  final double importo;
  final String tipo; // 'entrata', 'uscita' o 'trasferimento'
  final String categoriaId;
  final String sottocategoriaId;
  final String contoId;
  final String? contoDestinazioneId; // Per i trasferimenti
  final DateTime data;
  final bool isRicorrente;
  final String? frequenzaRicorrenza; // 'giornaliera', 'settimanale', 'mensile', 'annuale'
  final DateTime? dataFineRicorrenza;
  final String? transazionePadreId; // ID della transazione originale per le ricorrenze
  final DateTime dataCreazione;
  final DateTime dataModifica;
  // Campi aggiuntivi per compatibilità Kotlin
  final String profileId;
  final String nome; // Alias per titolo
  final String note; // Alias per descrizione
  final String obiettivoId;
  final String contoDestId; // Alias per contoDestinazioneId
  final int timestamp;

  Transazione({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.importo,
    required this.tipo,
    required this.categoriaId,
    required this.sottocategoriaId,
    required this.contoId,
    this.contoDestinazioneId,
    required this.data,
    this.isRicorrente = false,
    this.frequenzaRicorrenza,
    this.dataFineRicorrenza,
    this.transazionePadreId,
    required this.dataCreazione,
    required this.dataModifica,
    // Campi aggiuntivi per compatibilità Kotlin
    required this.profileId,
    String? nome,
    String? note,
    this.obiettivoId = '',
    String? contoDestId,
    int? timestamp,
  }) : nome = nome ?? titolo,
       note = note ?? descrizione,
       contoDestId = contoDestId ?? contoDestinazioneId ?? '',
       timestamp = timestamp ?? data.millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    // Formato compatibile Kotlin
    return {
      'id': id,
      'titolo': titolo,
      'nome': nome, // Aggiunto per Kotlin
      'descrizione': descrizione,
      'note': note, // Aggiunto per Kotlin
      'importo': importo,
      'tipo': _kotlinTipo(tipo), // Converti in formato Kotlin
      'categoriaId': categoriaId,
      'sottocategoriaId': sottocategoriaId,
      'contoId': contoId,
      'contoDestinazioneId': contoDestinazioneId,
      'contoDestId': contoDestId, // Aggiunto per Kotlin
      'data': _formatDataKotlin(data), // Formato YYYY-MM-DD per Kotlin
      'ricorrente': isRicorrente, // Kotlin usa 'ricorrente' invece di 'isRicorrente'
      'frequenzaRicorrenza': frequenzaRicorrenza,
      'dataFineRicorrenza': dataFineRicorrenza?.toIso8601String(),
      'transazionePadreId': transazionePadreId,
      'dataCreazione': dataCreazione.toIso8601String(),
      'dataModifica': dataModifica.toIso8601String(),
      'profileId': profileId, // Aggiunto per Kotlin
      'obiettivoId': obiettivoId, // Aggiunto per Kotlin
      'timestamp': timestamp, // Aggiunto per Kotlin
    };
  }

  // Helper per convertire tipo Flutter -> Kotlin
  static String _kotlinTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'uscita': return 'Expense';
      case 'entrata': return 'Income';
      case 'trasferimento': return 'Transfer';
      default: return 'Expense';
    }
  }

  // Helper per formattare data in formato Kotlin (YYYY-MM-DD)
  static String _formatDataKotlin(DateTime data) {
    return '${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  }

  factory Transazione.fromMap(Map<String, dynamic> map) {
    String titolo = map['titolo']?.toString() ?? map['nome']?.toString() ?? '';
    String descrizione = map['descrizione']?.toString() ?? map['note']?.toString() ?? '';
    String? contoDestinazione = map['contoDestinazioneId']?.toString() ?? map['contoDestId']?.toString();
    
    return Transazione(
      id: map['id']?.toString() ?? '',
      titolo: titolo,
      descrizione: descrizione,
      importo: _parseDouble(map['importo']),
      tipo: _normalizeTipo(map['tipo']?.toString() ?? ''),
      categoriaId: map['categoriaId']?.toString() ?? '',
      sottocategoriaId: map['sottocategoriaId']?.toString() ?? '',
      contoId: map['contoId']?.toString() ?? '',
      contoDestinazioneId: contoDestinazione,
      data: _parseDateTime(map['data']),
      isRicorrente: map['isRicorrente'] == true || map['ricorrente'] == true, // Supporta entrambi i formati
      frequenzaRicorrenza: map['frequenzaRicorrenza']?.toString(),
      dataFineRicorrenza: map['dataFineRicorrenza'] != null 
          ? _parseDateTime(map['dataFineRicorrenza']) 
          : null,
      transazionePadreId: map['transazionePadreId']?.toString(),
      dataCreazione: _parseDateTime(map['dataCreazione']),
      dataModifica: _parseDateTime(map['dataModifica']),
      // Campi aggiuntivi per compatibilità Kotlin
      profileId: map['profileId']?.toString() ?? '',
      nome: map['nome']?.toString() ?? titolo,
      note: map['note']?.toString() ?? descrizione,
      obiettivoId: map['obiettivoId']?.toString() ?? '',
      contoDestId: map['contoDestId']?.toString() ?? contoDestinazione ?? '',
      timestamp: map['timestamp'] is int 
          ? map['timestamp'] as int 
          : _parseDateTime(map['data']).millisecondsSinceEpoch,
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

  static String _normalizeTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'expense':
      case 'uscita':
        return 'uscita';
      case 'income':
      case 'entrata':
        return 'entrata';
      case 'transfer':
      case 'trasferimento':
        return 'trasferimento';
      default:
        return 'uscita'; // Default
    }
  }

  Transazione copyWith({
    String? id,
    String? titolo,
    String? descrizione,
    double? importo,
    String? tipo,
    String? categoriaId,
    String? sottocategoriaId,
    String? contoId,
    String? contoDestinazioneId,
    DateTime? data,
    bool? isRicorrente,
    String? frequenzaRicorrenza,
    DateTime? dataFineRicorrenza,
    String? transazionePadreId,
    DateTime? dataCreazione,
    DateTime? dataModifica,
    String? profileId,
    String? nome,
    String? note,
    String? obiettivoId,
    String? contoDestId,
    int? timestamp,
  }) {
    return Transazione(
      id: id ?? this.id,
      titolo: titolo ?? this.titolo,
      descrizione: descrizione ?? this.descrizione,
      importo: importo ?? this.importo,
      tipo: tipo ?? this.tipo,
      categoriaId: categoriaId ?? this.categoriaId,
      sottocategoriaId: sottocategoriaId ?? this.sottocategoriaId,
      contoId: contoId ?? this.contoId,
      contoDestinazioneId: contoDestinazioneId ?? this.contoDestinazioneId,
      data: data ?? this.data,
      isRicorrente: isRicorrente ?? this.isRicorrente,
      frequenzaRicorrenza: frequenzaRicorrenza ?? this.frequenzaRicorrenza,
      dataFineRicorrenza: dataFineRicorrenza ?? this.dataFineRicorrenza,
      transazionePadreId: transazionePadreId ?? this.transazionePadreId,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataModifica: dataModifica ?? this.dataModifica,
      profileId: profileId ?? this.profileId,
      nome: nome ?? this.nome,
      note: note ?? this.note,
      obiettivoId: obiettivoId ?? this.obiettivoId,
      contoDestId: contoDestId ?? this.contoDestId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Calcola la prossima data di ricorrenza
  DateTime? getProssimaDataRicorrenza() {
    if (!isRicorrente || frequenzaRicorrenza == null) return null;
    
    final now = DateTime.now();
    if (dataFineRicorrenza != null && now.isAfter(dataFineRicorrenza!)) {
      return null; // La ricorrenza è terminata
    }

    DateTime prossimaData = data;
    
    while (prossimaData.isBefore(now)) {
      switch (frequenzaRicorrenza!) {
        case 'giornaliera':
          prossimaData = prossimaData.add(const Duration(days: 1));
          break;
        case 'settimanale':
          prossimaData = prossimaData.add(const Duration(days: 7));
          break;
        case 'mensile':
          prossimaData = DateTime(
            prossimaData.year,
            prossimaData.month + 1,
            prossimaData.day,
          );
          break;
        case 'annuale':
          prossimaData = DateTime(
            prossimaData.year + 1,
            prossimaData.month,
            prossimaData.day,
          );
          break;
      }
      
      if (dataFineRicorrenza != null && prossimaData.isAfter(dataFineRicorrenza!)) {
        return null; // La ricorrenza è terminata
      }
    }
    
    return prossimaData;
  }

  /// Verifica se la transazione è scaduta (per ricorrenze)
  bool get isScaduta {
    if (!isRicorrente) return false;
    final prossimaData = getProssimaDataRicorrenza();
    return prossimaData == null || prossimaData.isBefore(DateTime.now());
  }

  /// Ottiene il testo della frequenza per l'UI
  String get frequenzaTesto {
    switch (frequenzaRicorrenza) {
      case 'giornaliera':
        return 'Ogni giorno';
      case 'settimanale':
        return 'Ogni settimana';
      case 'mensile':
        return 'Ogni mese';
      case 'annuale':
        return 'Ogni anno';
      default:
        return 'Una tantum';
    }
  }
}
