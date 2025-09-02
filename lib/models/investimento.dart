class Investimento {
    final String id;
    String nome;
    double importoInvestito;
    int quantita;
    double valoreAttuale;
    final String dataAcquisto;
    final String contoId;
    final String profileId;

    Investimento({
        this.id = "",
        this.nome = "",
        this.importoInvestito = 0.0,
        this.quantita = 1,
        this.valoreAttuale = 0.0,
        this.dataAcquisto = "",
        this.contoId = "",
        this.profileId = "",
    });
}
