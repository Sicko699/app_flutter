class Sottocategoria {
    final String id;
    String nome;

    Sottocategoria({
        required this.id,
        required this.nome,
    });

    // Converte la sottocategoria in una Map per Firestore
    Map<String, dynamic> toMap() {
        return {
            'id': id,
            'nome': nome,
        };
    }

    // Crea una Sottocategoria da una Map di Firestore
    factory Sottocategoria.fromMap(Map<String, dynamic> map) {
        return Sottocategoria(
            id: map['id'] ?? '',
            nome: map['nome'] ?? '',
        );
    }

    // Copia la sottocategoria con nuovi valori
    Sottocategoria copyWith({
        String? id,
        String? nome,
    }) {
        return Sottocategoria(
            id: id ?? this.id,
            nome: nome ?? this.nome,
        );
    }
}
