class VenditaInvestimento {
  final String id;
  final String investimentoId;
  String nome;
  int quantita;
  double importoVendita;
  final String dataVendita;
  final String contoId;
  final String profileId;

  VenditaInvestimento({
    this.id = "",
    this.investimentoId = "",
    this.nome = "",
    this.quantita = 0,
    this.importoVendita = 0.0,
    this.dataVendita = "",
    this.contoId = "",
    this.profileId = "",
  });
}
