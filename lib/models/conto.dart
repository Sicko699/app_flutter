class Conto {
    final String id;
    String nome;
    String tipo;
    double saldo;
    String profileId;

    Conto({
        required this.id,
        required this.nome,
        required this.tipo,
        required this.saldo,
        required this.profileId,
    });

    // Converte il conto in una Map per Firestore
    Map<String, dynamic> toMap() {
        return {
            'id': id,
            'nome': nome,
            'tipo': tipo,
            'saldo': saldo,
            'profileId': profileId,
        };
    }

    // Crea un Conto da una Map di Firestore
    factory Conto.fromMap(Map<String, dynamic> map) {
        return Conto(
            id: map['id'] ?? '',
            nome: map['nome'] ?? '',
            tipo: map['tipo'] ?? '',
            saldo: _parseDouble(map['saldo']),
            profileId: map['profileId'] ?? '',
        );
    }

    // Metodo helper per convertire valori numerici in double
    static double _parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
    }

    // Copia il conto con nuovi valori
    Conto copyWith({
        String? id,
        String? nome,
        String? tipo,
        double? saldo,
        String? profileId,
    }) {
        return Conto(
            id: id ?? this.id,
            nome: nome ?? this.nome,
            tipo: tipo ?? this.tipo,
            saldo: saldo ?? this.saldo,
            profileId: profileId ?? this.profileId,
        );
    }
}