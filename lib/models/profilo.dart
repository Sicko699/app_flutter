class ProfiloUtente {
  String id;
  String nome;
  String cognome;
  String dataDiNascita;
  String email;
  String? avatarUri;
  bool primoAccesso;
  DateTime? dataCreazione;
  DateTime? dataUltimoAccesso;

  ProfiloUtente({
    this.id = "",
    this.nome = "",
    this.cognome = "",
    this.dataDiNascita = "",
    this.email = "",
    this.avatarUri,
    this.primoAccesso = true,
    this.dataCreazione,
    this.dataUltimoAccesso,
  });

  // Converte il profilo in una Map per Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cognome': cognome,
      'dataDiNascita': dataDiNascita,
      'email': email,
      'avatarUri': avatarUri,
      'primoAccesso': primoAccesso,
      'dataCreazione': dataCreazione?.toIso8601String(),
      'dataUltimoAccesso': dataUltimoAccesso?.toIso8601String(),
    };
  }

  // Crea un ProfiloUtente da una Map di Firestore
  factory ProfiloUtente.fromMap(Map<String, dynamic> map) {
    return ProfiloUtente(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      cognome: map['cognome'] ?? '',
      dataDiNascita: map['dataDiNascita'] ?? '',
      email: map['email'] ?? '',
      avatarUri: map['avatarUri'],
      primoAccesso: map['primoAccesso'] ?? true,
      dataCreazione: map['dataCreazione'] != null 
          ? DateTime.parse(map['dataCreazione']) 
          : null,
      dataUltimoAccesso: map['dataUltimoAccesso'] != null 
          ? DateTime.parse(map['dataUltimoAccesso']) 
          : null,
    );
  }

  // Copia il profilo con nuovi valori
  ProfiloUtente copyWith({
    String? id,
    String? nome,
    String? cognome,
    String? dataDiNascita,
    String? email,
    String? avatarUri,
    bool? primoAccesso,
    DateTime? dataCreazione,
    DateTime? dataUltimoAccesso,
  }) {
    return ProfiloUtente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cognome: cognome ?? this.cognome,
      dataDiNascita: dataDiNascita ?? this.dataDiNascita,
      email: email ?? this.email,
      avatarUri: avatarUri ?? this.avatarUri,
      primoAccesso: primoAccesso ?? this.primoAccesso,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataUltimoAccesso: dataUltimoAccesso ?? this.dataUltimoAccesso,
    );
  }
}
